@tool
extends MarginContainer

var current_fact: ReactionFactItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var fact_type_menu_text_options: Dictionary = {
	"string": "String", "number": "Number", "boolean": "Boolean"
}

var fact_scope_menu_text_options: Dictionary = {
	"global": "Global", "event": "Event"
}

@onready var facts_list: ReactionItemList = %FactsList
@onready var fact_data_container: VBoxContainer = %FactDataContainer

@onready var fact_references_dialog: AcceptDialog = %FactReferenceAcceptDialog
@onready var fact_references_label: RichTextLabel = %FactReferencesRichTextLabel

@onready var warning_dialog: AcceptDialog = %WarningAcceptDialog

# fact inputs
@onready var fact_label_edit: LineEdit = %FactNameInputLineEdit
@onready var fact_uid_value_edit: LineEdit = %FactUidValue
@onready var fact_is_enum_check: CheckButton = %FactIsEnumCheckButton
@onready var fact_hint_string_container: BoxContainer = %FactHintStringInputContainer
@onready var fact_is_signal_check: CheckButton = %FactIsSignalCheckButton
@onready var fact_hint_string_edit: LineEdit = %FactHintStringLineEdit
@onready var fact_type_menu: MenuButton = %FactTypeMenuButton
@onready var fact_scope_menu: MenuButton = %FactScopeMenuButton
@onready var fact_tags_multiselect: ReactionUIMultiselect = %TabsMultiselect
@onready var fact_have_default_value_check_box: CheckButton = %FactHaveDefaultValueCheckButton
@onready var fact_have_default_value_container: HBoxContainer = %FactDefaultValueContainer
@onready var fact_default_value_edit: LineEdit = %FactDefaultValueStringLineEdit
@onready var fact_default_value_number: SpinBox = %FactDefaultValueNumberSpinBox
@onready var fact_default_value_enum: MenuButton = %FactDefaultValueEnumMenuButton
@onready var fact_default_value_bool: CheckBox = %FactDefaultValueBooleanCheckBox


func _ready() -> void:
	var type_menu: PopupMenu = fact_type_menu.get_popup()
	type_menu.index_pressed.connect(_on_fact_type_menu_index_pressed)
	type_menu.clear()

	var fact_type_menu_text_options_values = fact_type_menu_text_options.values()
	for i in range(fact_type_menu_text_options_values.size()):
		type_menu.add_item(fact_type_menu_text_options_values[i], i)
		
	
	var scope_menu: PopupMenu = fact_scope_menu.get_popup()
	scope_menu.index_pressed.connect(_on_fact_scope_menu_index_pressed)
	scope_menu.clear()

	var fact_scope_menu_text_options_values = fact_scope_menu_text_options.values()
	for i in range(fact_scope_menu_text_options_values.size()):
		scope_menu.add_item(fact_scope_menu_text_options_values[i], i)
	
	var fact_default_value_number_edit: LineEdit = fact_default_value_number.get_line_edit()
	fact_default_value_number_edit.text_submitted.connect(_on_fact_default_value_number_edit_submitted)
	
	var default_value_popup: Popup = fact_default_value_enum.get_popup()
	default_value_popup.index_pressed.connect(_on_fact_default_value_enum_index_pressed)
	
	fact_data_container.visible = false
	
	ReactionSignals.database_selected.connect(setup_facts)


func _update_fact_default_value_input():
	fact_default_value_edit.visible = false
	fact_default_value_number.visible = false
	fact_default_value_enum.visible = false
	fact_default_value_bool.visible = false
	
	if current_fact:
		if current_fact.type == TYPE_STRING and not current_fact.is_enum:
			fact_default_value_edit.visible = true
			if current_fact.default_value:
				fact_default_value_edit.text = str(current_fact.default_value)
			
		if current_fact.type == TYPE_STRING and current_fact.is_enum:
			fact_default_value_enum.visible = true
			fact_default_value_enum.text = "Select value"
			if current_fact.default_value:
				fact_default_value_enum.text = str(current_fact.default_value)
				
			var fact_default_value_popup: PopupMenu = fact_default_value_enum.get_popup() 
			fact_default_value_popup.clear()
			for enum_value in current_fact.enum_names:
				fact_default_value_popup.add_item(enum_value)
		
		if current_fact.type == TYPE_INT:
			fact_default_value_number.visible = true
			var fact_default_value_number_edit: LineEdit = fact_default_value_number.get_line_edit()
			fact_default_value_number_edit.text = "0"
			if current_fact.default_value:
				fact_default_value_number_edit.text = str(current_fact.default_value)
			
		if current_fact.type == TYPE_BOOL:
			fact_default_value_bool.visible = true
			fact_default_value_bool.set_pressed_no_signal(!!current_fact.default_value)
			
		fact_have_default_value_container.visible = current_fact.have_default_value
		fact_have_default_value_check_box.set_pressed_no_signal(current_fact.have_default_value)


func setup_facts() -> void:
	facts_list.setup_items()


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
	fact_is_signal_check.set_pressed_no_signal(current_fact.trigger_signal_on_modified)
	
	fact_type_menu.text = _set_fact_type_menu_text(current_fact.type)
	fact_scope_menu.text = current_fact.scope
	fact_is_enum_check.set_pressed_no_signal(current_fact.is_enum)
	fact_hint_string_edit.text = current_fact.hint_string

	if fact_type_menu.text == fact_type_menu_text_options["string"]:
		_set_visibility_enum_hint(true)
	else:
		_set_visibility_enum_hint(false)
		
	fact_data_container.visible = true
	
	# fact_tags_multiselect.setup(current_fact, current_database.tags.values())
	_update_fact_default_value_input()


func _set_fact_property(property_name: StringName, value: Variant) -> void:
	current_fact.set(property_name, value)
	current_fact.update_sqlite()


func _set_visibility_enum_hint(value: bool) -> void:
	fact_is_enum_check.visible = value
	if value:
		fact_hint_string_container.visible = current_fact.is_enum
	else:
		fact_hint_string_container.visible = false


func _set_fact_type_value(is_visible_enum: bool, value: Variant, menu_text: String) -> void:
	_set_fact_property("type", value)
	_set_visibility_enum_hint(is_visible_enum)
	fact_type_menu.text = menu_text
	_update_fact_default_value_input()


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
	

func _on_fact_is_enum_check_button_toogled(toggled_on: bool):
	_set_fact_property(
		"is_enum", 
		toggled_on
	)
	if toggled_on:
		_set_fact_property("hint_string", fact_hint_string_edit.text)
		
	fact_hint_string_container.visible = toggled_on
	_update_fact_default_value_input()
	
	
func _on_fact_hint_string_line_edit_text_submitted(new_text):
	_set_fact_property("hint_string", new_text)


func _on_fact_type_menu_index_pressed(index):
	if true: #not current_fact.have_references():
		var popup = fact_type_menu.get_popup()
		var label = popup.get_item_text(index)
		if fact_type_menu_text_options["string"] == label:
			_set_fact_type_value(true, TYPE_STRING, label)
		if fact_type_menu_text_options["boolean"] == label:
			_set_fact_type_value(false,  TYPE_BOOL, label)
		if fact_type_menu_text_options["number"] == label:
			_set_fact_type_value(false, TYPE_INT, label)
	else:
		warning_dialog.dialog_text = "Cannot modify type. The fact have references."
		warning_dialog.popup_centered()
		
		
func _on_fact_scope_menu_index_pressed(index):
	var popup = fact_scope_menu.get_popup()
	var label = popup.get_item_text(index)
	_set_fact_property("scope", label)
	fact_scope_menu.text = label
		

func _on_facts_list_item_added(index, item_data):
	_set_fact(item_data)


func _on_facts_list_item_removed(index, item_data):
	if facts_list.items_list.item_count > 0:
		_set_fact(facts_list.current_item)
	else:
		fact_data_container.visible = false


func _on_facts_list_item_list_updated():
	fact_data_container.visible = false


func _on_show_fact_references_button_pressed():
	var text_result = ""
	var references_count = 0
	
	if references_count == 0:
		text_result = "No references found"
		
	fact_references_label.text = ("Cant of references: %s \n" % references_count) + text_result
	fact_references_dialog.popup_centered()


func _on_fact_default_value_string_line_edit_text_submitted(new_text):
	_set_fact_property("default_value", new_text)


func _on_fact_default_value_boolean_check_box_toggled(toggled_on):
	_set_fact_property("default_value", toggled_on)
	
	
func _on_fact_default_value_number_edit_submitted(new_text):
	_set_fact_property("default_value", new_text)
	
	
func _on_fact_default_value_enum_index_pressed(index: int) -> void:
	var popup = fact_default_value_enum.get_popup()
	var label = popup.get_item_text(index)
	_set_fact_property("default_value", label)
	fact_default_value_enum.text = label


func _on_fact_have_default_value_check_button_toggled(toggled_on):
	_set_fact_property("have_default_value", toggled_on)
	_update_fact_default_value_input()
