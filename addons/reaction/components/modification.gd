@tool
class_name Modification
extends ListObjectFormItem


var label_input: LineEdit
var fact_search_menu: HBoxContainer
var operation_label: Label
var operation_menu: MenuButton
var value_label: Label
var value_input: LineEdit
var value_numeric_input: SpinBox
var value_numeric_text_edit: LineEdit
var enum_values_menu: MenuButton
var boolean_value_check: CheckBox


func _ready():
	super()
	remove_object_function_name = "remove_modification_by_index"
	object_name = "modification"


func _set_no_visible_inputs() -> void:
	value_label.visible = false
	value_input.visible = false
	value_numeric_input.visible = false
	boolean_value_check.visible = false
	enum_values_menu.visible = false


func _set_operation_input_visibility(value: bool) -> void:
	operation_menu.visible = value
	operation_label.visible = value


func update_operation_menu_items() -> void:
	var operation_menu_labels : Array[String]
	var menu: PopupMenu = operation_menu.get_popup()
	
	if not item_object.fact:
		operation_menu_labels = []
		_set_operation_input_visibility(false)
	elif item_object.fact.type == TYPE_INT:
		operation_menu_labels = ["=", "+", "-", "erase"]
		_set_operation_input_visibility(true)
	else:
		operation_menu_labels = ["=", "erase"]
		_set_operation_input_visibility(true)
	
	menu.clear()
	for operation in operation_menu_labels:
		menu.add_item(operation)
	
	if item_object.operation:
		operation_menu.text = item_object.operation
	else:
		operation_menu.text = "Select opt"
	
	
func _get_value_a() -> Variant:
	if item_object.modification_value:
		return item_object.modification_value
	else:
		match item_object.fact.type:
			TYPE_STRING:
				return "Select value"
			_:
				return 0
	
	
func update_values_input() -> void:
	_set_no_visible_inputs()
	
	if item_object.fact:
		value_label.visible = true
		
		var current_value_a = _get_value_a()
			
		if item_object.fact.type == TYPE_INT:
			value_numeric_input.visible = true
			value_numeric_input.set_value_no_signal(int(current_value_a))
			
		if item_object.fact.type == TYPE_BOOL:
			boolean_value_check.visible = true
			boolean_value_check.set_pressed_no_signal(bool(current_value_a))
			
		if item_object.fact.type == TYPE_STRING and not item_object.fact.is_enum:
			value_input.visible = true
			value_input.text = str(current_value_a)
			
		if item_object.fact.type == TYPE_STRING and item_object.fact.is_enum:
			enum_values_menu.visible = true
			 
			var enum_menu = enum_values_menu.get_popup()
			enum_menu.clear()
			var values = item_object.fact.enum_names
			for value in values:
				enum_menu.add_item(value)
				
			enum_values_menu.text = str(current_value_a)
			
			
func setup(database: ReactionDatabase, parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:
	index_label = %IndexLabel
	label_input = %LabelLineEdit
	fact_search_menu = %FactsSearchMenu
	operation_label = %OperationLabel
	operation_menu = %OperationMenuButton
	value_label = %ValueLabel
	value_input = %ValueLineEdit
	value_numeric_input = %ValueSpinBox
	value_numeric_text_edit = value_numeric_input.get_line_edit()
	enum_values_menu = %EnumValuesMenuButton
	boolean_value_check = %BooleanValueCheckBox
	
	var operation_popup_menu: PopupMenu = operation_menu.get_popup()
	var values_popup_menu: PopupMenu = enum_values_menu.get_popup()
	
	operation_popup_menu.index_pressed.connect(_on_operation_menu_index_pressed)
	values_popup_menu.index_pressed.connect(_on_values_menu_index_pressed)
	value_numeric_text_edit.text_submitted.connect(_on_value_numeric_text_submitted)
	
	
	current_database = database
	current_parent_object = parent_object
	object_index = index
	item_object = object
	
	label_input.text = item_object.label
	
	if item_object.fact:
		fact_search_menu.search_input_text = item_object.fact.label
	
	fact_search_menu.items_list = current_database.global_facts.values()
	
	update_operation_menu_items()
	update_values_input()
	
	if is_new_object:
		operation_menu.text = "Select operation"
		

func _set_modification_property(property_name: StringName, value: Variant) -> void:
	item_object.set(property_name, value)
	current_database.save_data()


### Signals


func _on_facts_search_menu_item_selected(item):
	operation_menu.text = "Select operation"
	enum_values_menu.text = "Select value"
	
	if item_object.fact:
		current_database.remove_fact_reference_log(item_object)
	
	_set_modification_property("fact", fact_search_menu.current_item)
	
	var new_item_log: ReactionReferenceLogItem = ReactionReferenceLogItem.new()
	new_item_log.update_log_objects(item_object, current_database)
	current_database.add_fact_reference_log(new_item_log)
	current_database.save_data()
	
	update_operation_menu_items()
	update_values_input()


func _on_label_line_edit_text_submitted(new_text):
	_set_modification_property("label", new_text)
	
	
func _on_value_numeric_text_submitted(new_text: String) -> void:
	_set_modification_property("modification_value", int(new_text))
	value_numeric_text_edit.release_focus()
	
	
func _on_operation_menu_index_pressed(index: int) -> void:
	var popup = operation_menu.get_popup()
	var label = popup.get_item_text(index)
	_set_modification_property("operation", label)
	operation_menu.text = label
	update_values_input()


func _on_value_line_edit_text_submitted(new_text):
	_set_modification_property("modification_value", new_text)
	

func _on_values_menu_index_pressed(index: int):
	var popup = enum_values_menu.get_popup()
	var label = popup.get_item_text(index)
	_set_modification_property("modification_value", label)
	enum_values_menu.text = label
	enum_values_menu.tooltip_text = label


func _on_boolean_value_check_box_toggled(toggled_on):
	_set_modification_property("modification_value", toggled_on)
