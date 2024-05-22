@tool
extends MarginContainer

var current_database: ReactionDatabase

var current_fact: ReactionFactItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var fact_type_menu_text_options: Dictionary = {
	"string": "String", "number": "Number", "boolean": "Boolean"
}

@onready var facts_list: VBoxContainer = %FactsList
@onready var fact_data_container: VBoxContainer = %FactDataContainer

# fact inputs
@onready var fact_label_edit: LineEdit = %FactNameInputLineEdit
@onready var fact_uid_value_edit: LineEdit = %FactUidValue
@onready var fact_is_enum_check: Button = %FactIsEnumCheckButton
@onready var fact_hint_string_container: BoxContainer = %FactHintStringInputContainer
@onready var fact_is_signal_check: Button = %FactIsSignalCheckButton
@onready var fact_hint_string_edit: LineEdit = %FactHintStringLineEdit
@onready var fact_type_menu: MenuButton = %FactTypeMenuButton


func _ready() -> void:
	var menu: PopupMenu = fact_type_menu.get_popup()
	menu.index_pressed.connect(_on_fact_type_menu_index_pressed)
	menu.clear()

	var fact_type_menu_text_options_values = fact_type_menu_text_options.values()
	for i in range(fact_type_menu_text_options_values.size()):
		menu.add_item(fact_type_menu_text_options_values[i], i)
	
	fact_data_container.visible = false


func setup_facts(database: ReactionDatabase) -> void:
	current_database = database
	facts_list.setup_items(current_database, current_database)


func _set_fact_type_menu_text(value: Variant.Type) -> String:
	match value:
		TYPE_BOOL:
			return fact_type_menu_text_options["boolean"]
		TYPE_INT:
			return fact_type_menu_text_options["number"]
		TYPE_STRING:
			return fact_type_menu_text_options["string"]
		_:
			return fact_type_menu_text_options["string"]


func _set_fact(fact_data: ReactionFactItem) -> void:
	current_fact = fact_data
	# set input default values
	fact_uid_value_edit.text = current_fact.uid
	fact_label_edit.text = current_fact.label
	fact_is_signal_check.button_pressed = current_fact.trigger_signal_on_modified

	fact_is_enum_check.button_pressed = current_fact.is_enum
	fact_hint_string_container.visible = current_fact.is_enum
	fact_hint_string_edit.text = current_fact.hint_string
	fact_type_menu.text = _set_fact_type_menu_text(current_fact.type)

	if fact_type_menu.text == fact_type_menu_text_options["string"]:
		_set_visibility_enum_hint(true)
	else:
		_set_visibility_enum_hint(false)
		
	fact_data_container.visible = true


func _set_fact_property(property_name: StringName, value: Variant) -> void:
	current_fact.set(property_name, value)
	current_database.save_data()


func _set_visibility_enum_hint(value: bool) -> void:
	fact_is_enum_check.visible = value
	fact_hint_string_container.visible = value


func _set_fact_type_value(is_visible_enum: bool, value: Variant, menu_text: String) -> void:
	_set_fact_property( "type", value)
	_set_visibility_enum_hint(is_visible_enum)
	fact_type_menu.text = menu_text


### signals

func _on_facts_list_item_selected(item_data: ReactionFactItem) -> void:
	_set_fact(item_data)


func _on_fact_name_input_line_edit_text_submitted(new_text: String) -> void:
	_set_fact_property("label", new_text)
	facts_list.items_list.set_item_text(facts_list.current_item_index, new_text)


func _on_fact_is_signal_check_button_pressed():
	_set_fact_property(
		"trigger_signal_on_modified",
		 not current_fact.trigger_signal_on_modified
	)
	

func _on_fact_is_enum_check_button_pressed():
	_set_fact_property(
		"trigger_signal_on_modified", not current_fact.is_enum
	)
	_set_fact_property("hint_string", fact_hint_string_edit.text)
	fact_hint_string_container.visible = current_fact.is_enum

	
func _on_fact_hint_string_line_edit_text_submitted(new_text):
	_set_fact_property("hint_string", new_text)


func _on_fact_type_menu_index_pressed(index):
	var popup = fact_type_menu.get_popup()
	var label = popup.get_item_text(index)
	undo_redo.create_action("Change type")
	if fact_type_menu_text_options["string"] == label:
		undo_redo.add_do_method(
			self,
			"_set_fact_type_value",
			true, TYPE_STRING, label
		)
	if fact_type_menu_text_options["boolean"] == label:
		undo_redo.add_do_method(
			self,
			"_set_fact_type_value",
		 false,  TYPE_BOOL, label
		)
	if fact_type_menu_text_options["number"] == label:
		undo_redo.add_do_method(
			self,
				"_set_fact_type_value",
		false, TYPE_INT, label
		)

	undo_redo.add_undo_method(
		self,
		"_set_fact_type_value",
		
		current_fact.type == TYPE_STRING,
		current_fact.type,
		fact_type_menu.text
		
	)
	undo_redo.commit_action()


func _on_facts_list_item_added(index, item_data):
	_set_fact(item_data)


func _on_facts_list_item_removed(index, item_data):
	if current_database.global_facts.size() > 0:
		_set_fact(facts_list.current_item)
	else:
		fact_data_container.visible = false
