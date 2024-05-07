@tool
extends MarginContainer

var current_database: ReactionDatabase

var selected_item_index: int = -1

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var fact_type_menu_text_options: Dictionary = {
	"string": "String", "number": "Number", "boolean": "Boolean"
}

@onready var facts_list: ItemList = %FactsList
@onready var fact_data_container: VBoxContainer = %FactDataContainer
@onready var remove_fact_button: Button = %RemoveFactButton

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

	if not facts_list.is_anything_selected():
		remove_fact_button.disabled = true
		fact_data_container.visible = false


func setup_facts(database: ReactionDatabase) -> void:
	facts_list.clear()
	remove_fact_button.disabled = true
	fact_data_container.visible = false

	current_database = database
	for fact in current_database.global_facts.values():
		var index = facts_list.add_item(fact.label)
		facts_list.set_item_metadata(index, fact)


func _add_fact(fact: ReactionFactItem) -> void:
	current_database.add_fact(fact)
	var index = facts_list.add_item(fact.label)
	facts_list.set_item_metadata(index, fact)
	_set_fact(index)


func _remove_fact(data: Dictionary) -> void:
	current_database.remove_fact(data["fact"].uid)
	facts_list.remove_item(data["index"])

	if current_database.global_facts.size() > 0:
		_set_fact(0)
	else:
		selected_item_index = -1
		remove_fact_button.disabled = true
		fact_data_container.visible = false
		facts_list.deselect_all()


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


func _set_fact(index: int) -> void:
	var current_fact: ReactionFactItem = facts_list.get_item_metadata(index)
	selected_item_index = index
	facts_list.select(index)

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

	remove_fact_button.disabled = false
	fact_data_container.visible = true


func _set_fact_property(params: Dictionary) -> void:
	var current_fact = facts_list.get_item_metadata(selected_item_index)
	current_fact.set(params["property_name"], params["value"])
	current_database.save_data()


func _set_visibility_enum_hint(value: bool) -> void:
	fact_is_enum_check.visible = value
	fact_hint_string_container.visible = value


func _set_fact_type_value(params: Dictionary) -> void:
	_set_fact_property({"property_name": "type", "value": params["value"]})
	_set_visibility_enum_hint(params["is_visible_enum"])
	fact_type_menu.text = params["menu_text"]


### signals


func _on_add_fact_button_pressed() -> void:
	var new_fact = ReactionFactItem.new()

	undo_redo.create_action("Add fact")
	undo_redo.add_do_method(self, "_add_fact", new_fact)
	undo_redo.add_undo_method(
		self, "_remove_fact", {"fact": new_fact, "index": current_database.global_facts.size()}
	)
	undo_redo.commit_action()


func _on_remove_fact_button_pressed() -> void:
	undo_redo.create_action("Remove fact")
	undo_redo.add_do_method(
		self,
		"_remove_fact",
		{"fact": facts_list.get_item_metadata(selected_item_index), "index": selected_item_index}
	)
	undo_redo.add_undo_method(self, "_add_fact", facts_list.get_item_metadata(selected_item_index))
	undo_redo.commit_action()


func _on_facts_list_item_selected(index: int) -> void:
	undo_redo.create_action("Select fact")
	undo_redo.add_do_method(self, "_set_fact", index)
	if selected_item_index != -1:
		undo_redo.add_undo_method(self, "_set_fact", selected_item_index)
	undo_redo.commit_action()


func _on_fact_name_input_line_edit_text_submitted(new_text: String) -> void:
	_set_fact_property({"property_name": "label", "value": new_text})
	facts_list.set_item_text(selected_item_index, new_text)


func _on_fact_is_signal_check_button_pressed():
	var current_fact: ReactionFactItem = facts_list.get_item_metadata(selected_item_index)
	_set_fact_property(
		{
			"property_name": "trigger_signal_on_modified",
			"value": not current_fact.trigger_signal_on_modified
		}
	)


func _on_fact_is_enum_check_button_pressed():
	var current_fact: ReactionFactItem = facts_list.get_item_metadata(selected_item_index)
	_set_fact_property(
		{"property_name": "trigger_signal_on_modified", "value": not current_fact.is_enum}
	)
	_set_fact_property({"property_name": "hint_string", "value": fact_hint_string_edit.text})
	fact_hint_string_container.visible = current_fact.is_enum


func _on_fact_hint_string_line_edit_text_submitted(new_text):
	_set_fact_property({"property_name": "hint_string", "value": new_text})


func _on_fact_type_menu_index_pressed(index):
	var popup = fact_type_menu.get_popup()
	var label = popup.get_item_text(index)
	undo_redo.create_action("Change type")
	if fact_type_menu_text_options["string"] == label:
		undo_redo.add_do_method(
			self,
			"_set_fact_type_value",
			{"is_visible_enum": true, "value": TYPE_STRING, "menu_text": label}
		)
	if fact_type_menu_text_options["boolean"] == label:
		undo_redo.add_do_method(
			self,
			"_set_fact_type_value",
			{"is_visible_enum": false, "value": TYPE_BOOL, "menu_text": label}
		)
	if fact_type_menu_text_options["number"] == label:
		undo_redo.add_do_method(
			self,
			"_set_fact_type_value",
			{"is_visible_enum": false, "value": TYPE_INT, "menu_text": label}
		)

	var current_fact: ReactionFactItem = facts_list.get_item_metadata(selected_item_index)
	undo_redo.add_undo_method(
		self,
		"_set_fact_type_value",
		{
			"is_visible_enum": current_fact.type == TYPE_STRING,
			"value": current_fact.type,
			"menu_text": fact_type_menu.text
		}
	)
	undo_redo.commit_action()
