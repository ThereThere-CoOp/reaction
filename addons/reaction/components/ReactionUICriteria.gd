@tool
class_name ReactionUICriteria
extends ReactionUIListObjectFormItem

var label_input: LineEdit
var facts_function_button: Button
var fact_container: VBoxContainer
var fact_search_menu: ReactionUISearchMenu
var fact_function_managment: ReactionUIFunctionManagment
var operation_label: Label
var operation_menu: MenuButton
var value_a_label: Label
var value_a_input: LineEdit
var value_a_numeric_input: SpinBox
var value_a_numeric_text_edit: LineEdit
var enum_values_menu: MenuButton
var value_b_label: Label
var value_b_input: SpinBox
var value_b_text_edit: LineEdit
var boolean_value_check: CheckBox
var negate_check: CheckButton

@onready var warning_dialog: AcceptDialog = %WarningAcceptDialog
@onready var facts_functions_dialog: AcceptDialog = %FactsFunctionConfirmationDialog


func _ready():
	super()
	remove_object_function_name = "remove_criteria_by_index"
	object_name = "criteria"


func _set_no_visible_inputs() -> void:
	value_a_label.visible = false
	value_a_input.visible = false
	value_a_numeric_input.visible = false
	value_b_input.visible = false
	value_b_label.visible = false
	boolean_value_check.visible = false
	enum_values_menu.visible = false


func _set_operation_input_visibility(value: bool) -> void:
	operation_menu.visible = value
	operation_label.visible = value


func update_operation_menu_items() -> void:
	var operation_menu_labels : Array[String]
	var menu: PopupMenu = operation_menu.get_popup()
	
	if item_object is ReactionFunctionCriteriaItem:
		operation_menu_labels = ["=", "<", ">", "a<=x<=b"]
		_set_operation_input_visibility(true)
	elif not item_object.fact:
		operation_menu_labels = []
		_set_operation_input_visibility(false)
	elif item_object.fact.type == TYPE_INT:
		operation_menu_labels = ["=", "<", ">", "a<=x<=b"]
		_set_operation_input_visibility(true)
	else:
		operation_menu_labels = ["="]
		_set_operation_input_visibility(true)
	
	menu.clear()
	for operation in operation_menu_labels:
		menu.add_item(operation)
	
	if item_object.operation:
		operation_menu.text = item_object.operation
	else:
		operation_menu.text = "Select opt"
	
	
func _get_value_a() -> Variant:
	if item_object.value_a:
		return item_object.value_a
	else:
		if not item_object is ReactionFunctionCriteriaItem:
			match item_object.fact.type:
				TYPE_STRING:
					return "Select value"
				_:
					return 0
		else:
			return 0
		
				
				
func _check_input_range_values(min_value, max_value) -> bool:
	if item_object.operation == "a<=x<=b":
		if min_value != null and max_value != null:
			return int(min_value) <= int(max_value)
		return true
	return true
			
				
func _get_value_b() -> Variant:
	if item_object.value_b:
		return item_object.value_b
	else:
		return 0
	
	
func update_values_input() -> void:
	_set_no_visible_inputs()
	
	if item_object is ReactionFunctionCriteriaItem:
		value_a_label.visible = true
		
		var current_value_a = _get_value_a()
		var current_value_b = _get_value_b()
		value_a_numeric_input.visible = true
		value_a_numeric_input.set_value_no_signal(int(current_value_a))
		
		if item_object.operation == "a<=x<=b":
			value_b_label.visible = true
			value_b_input.visible = true
			value_b_input.set_value_no_signal(int(current_value_b))
		
	elif item_object.fact:
		value_a_label.visible = true
		
		var current_value_a = _get_value_a()
		
		var current_value_b = _get_value_b()
			
		if item_object.fact.type == TYPE_INT:
			value_a_numeric_input.visible = true
			value_a_numeric_input.set_value_no_signal(int(current_value_a))
			
		if item_object.fact.type == TYPE_BOOL:
			boolean_value_check.visible = true
			
			if current_value_a == null:
				current_value_a = false
			else:
				current_value_a = ReactionUtilities.get_boolean_from_string(current_value_a)
				
			boolean_value_check.set_pressed_no_signal(current_value_a)
		
		if item_object.fact.type == TYPE_STRING and not item_object.fact.is_enum:
			
			value_a_input.visible = true
			value_a_input.text = str(current_value_a)
			
		if item_object.fact.type == TYPE_STRING and item_object.fact.is_enum:
			enum_values_menu.visible = true
			 
			var enum_menu = enum_values_menu.get_popup()
			enum_menu.clear()
			var values = item_object.fact.enum_names
			for value in values:
				enum_menu.add_item(value)
				
			enum_values_menu.text = str(current_value_a)
		
		if item_object.operation == "a<=x<=b":
			value_b_input.visible = true
			value_b_label.visible = true
			value_b_input.set_value_no_signal(int(current_value_b))
			
			
func setup(parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:
	super(parent_object, object, index, is_new_object)
	
	label_input = %LabelLineEdit
	fact_container = %FactContainer
	fact_search_menu = %FactsSearchMenu
	facts_function_button = %FactsFunctionButton
	fact_function_managment = %FunctionManagment
	operation_label = %OperationLabel
	operation_menu = %OperationMenuButton
	value_a_label = %ValueLabel
	value_a_input = %ValueALineEdit
	value_a_numeric_input = %ValueSpinBox
	value_a_numeric_text_edit = value_a_numeric_input.get_line_edit()
	enum_values_menu = %EnumValuesMenuButton
	value_b_label = %ValueBLabel
	value_b_input = %ValueBSpinBox
	value_b_text_edit = value_b_input.get_line_edit()
	boolean_value_check = %BooleanValueCheckBox
	negate_check = %NegateCheckButton
	
	var operation_popup_menu: PopupMenu = operation_menu.get_popup()
	var values_popup_menu: PopupMenu = enum_values_menu.get_popup()
	
	operation_popup_menu.index_pressed.connect(_on_operation_menu_index_pressed)
	values_popup_menu.index_pressed.connect(_on_values_menu_index_pressed)
	value_a_numeric_text_edit.text_submitted.connect(_on_value_a_numeric_text_submitted)
	value_b_text_edit.text_submitted.connect(_on_value_b_text_submitted)
	
	label_input.text = item_object.label
	
	if item_object.fact and item_object.fact.sqlite_id and item_object.fact.sqlite_id != 0:
		fact_search_menu.search_input_text = item_object.fact.label
	
	var fact_resource: ReactionFactItem = ReactionFactItem.get_new_object()
	var facts_list = fact_resource.get_sqlite_list(null, true)
	fact_search_menu.items_list = facts_list
	
	negate_check.button_pressed = item_object.is_reverse
		
	update_operation_menu_items()
	update_values_input()
	
	if is_new_object:
		operation_menu.text = "Select operation"
	
	fact_function_managment.setup(object.serialize())
		
	fact_container.visible = true
	facts_function_button.visible = false
	
	if item_object is ReactionFunctionCriteriaItem:
		fact_container.visible = false
		facts_function_button.visible = true
	
	 


func _set_criteria_property(property_name: StringName, value: Variant) -> void:
	if property_name == "value_a":
		item_object.set_value_a(str(value))
	elif property_name == "value_b":
		item_object.set_value_b(str(value))
	else:
		item_object.set(property_name, value)
		
	item_object.update_sqlite()


func _show_warning_dialog(text: String):
	warning_dialog.dialog_text = text
	warning_dialog.popup_centered()
	
	
### Signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_facts_search_menu_item_selected(item):
	operation_menu.text = "Select operation"
	enum_values_menu.text = "Select value"
	
	var current_item = fact_search_menu.current_item
	
	_set_criteria_property("fact", current_item)
	
	if current_item.type == TYPE_BOOL:
		_set_criteria_property("value_a", "false")
	
	update_operation_menu_items()
	update_values_input()


func _on_label_line_edit_text_submitted(new_text):
	_set_criteria_property("label", new_text)
	
	
func _on_value_a_numeric_text_submitted(new_text: String) -> void:
	if _check_input_range_values(int(new_text), item_object.value_b):
		_set_criteria_property("value_a", int(new_text))
		value_a_numeric_text_edit.release_focus()
	else:
		_show_warning_dialog("Value a must less and equal than value b")
		value_a_numeric_text_edit.release_focus()
	
	
func _on_value_b_text_submitted(new_text: String) -> void:
	if _check_input_range_values(item_object.value_a, int(new_text)):
		_set_criteria_property("value_b", int(new_text))
		value_b_text_edit.release_focus()
	else:
		_show_warning_dialog("Value a must less and equal than value b")
		value_b_text_edit.release_focus()
	
	
func _on_operation_menu_index_pressed(index: int) -> void:
	var popup = operation_menu.get_popup()
	var label = popup.get_item_text(index)
	_set_criteria_property("operation", label)
	operation_menu.text = label
	update_values_input()


func _on_value_a_line_edit_text_submitted(new_text):
	_set_criteria_property("value_a", new_text)
	
	
func _on_values_menu_index_pressed(index: int):
	var popup = enum_values_menu.get_popup()
	var label = popup.get_item_text(index)
	_set_criteria_property("value_a", label)
	enum_values_menu.text = label
	enum_values_menu.tooltip_text = label


func _on_boolean_value_check_box_toggled(toggled_on):
	_set_criteria_property("value_a", toggled_on)


func _on_negate_check_button_toggled(toggled_on):
	_set_criteria_property("is_reverse", toggled_on)


func _on_facts_function_button_pressed():
	fact_function_managment.setup(item_object.serialize())
	facts_functions_dialog.popup_centered()


func _on_facts_function_confirmation_dialog_confirmed() -> void:
	if fact_function_managment.check_function():
		_set_criteria_property("function", fact_function_managment.get_function_string())


func _on_facts_search_menu_item_removed(item: Variant) -> void:
	operation_menu.text = "Select operation"
	enum_values_menu.text = "Select value"
	
	_set_criteria_property("fact", null)
	
	update_operation_menu_items()
	update_values_input()
