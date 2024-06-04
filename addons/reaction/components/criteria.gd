@tool
extends HBoxContainer

var current_database: ReactionDatabase

var current_rule: ReactionRuleItem

var criteria_index: int = -1

var criteria_object : ReactionRuleCriteria

@onready var remove_criteria_button: Button = %RemoveCriteriaButton

var label_input: LineEdit
var fact_search_menu: HBoxContainer
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


func _ready():
	call_deferred("apply_theme")


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
	
	if not criteria_object.fact:
		operation_menu_labels = []
		_set_operation_input_visibility(false)
	elif criteria_object.fact.type == TYPE_INT:
		operation_menu_labels = ["=", "<", ">", "a<=x<=b"]
		_set_operation_input_visibility(true)
	else:
		operation_menu_labels = ["="]
		_set_operation_input_visibility(true)
	
	menu.clear()
	for operation in operation_menu_labels:
		menu.add_item(operation)
	
	if criteria_object.operation:
		operation_menu.text = criteria_object.operation
	else:
		operation_menu.text = "Select opt"
	
	
func _get_value_a() -> Variant:
	if criteria_object.value_a:
		return criteria_object.value_a
	else:
		match criteria_object.fact.type:
			TYPE_STRING:
				return "Select value"
			_:
				return 0
	
				
func _get_value_b() -> Variant:
	if criteria_object.value_b:
		return criteria_object.value_b
	else:
		return 0
	
	
func update_values_input() -> void:
	_set_no_visible_inputs()
	
	if criteria_object.fact:
		value_a_label.visible = true
		
		var current_value_a = _get_value_a()
		
		var current_value_b = _get_value_b()
			
		if criteria_object.fact.type == TYPE_INT:
			value_a_numeric_input.visible = true
			value_a_numeric_input.set_value_no_signal(int(current_value_a))
			
		if criteria_object.fact.type == TYPE_BOOL:
			boolean_value_check.visible = true
			boolean_value_check.set_pressed_no_signal(bool(current_value_a))
			
		if criteria_object.fact.type == TYPE_STRING and not criteria_object.fact.is_enum:
			value_a_input.visible = true
			value_a_input.text = str(current_value_a)
			
		if criteria_object.fact.type == TYPE_STRING and criteria_object.fact.is_enum:
			enum_values_menu.visible = true
			 
			var enum_menu = enum_values_menu.get_popup()
			enum_menu.clear()
			var values = criteria_object.fact.enum_names
			for value in values:
				enum_menu.add_item(value)
				
			enum_values_menu.text = str(current_value_a)
		
		if criteria_object.operation == "a<=x<=b":
			value_b_input.visible = true
			value_b_label.visible = true
			value_b_input.set_value_no_signal(int(current_value_b))
			
			
func setup(database: ReactionDatabase, rule: ReactionRuleItem, criteria: ReactionRuleCriteria, index: int, is_new_criteria: bool = false) -> void:
	label_input = %LabelLineEdit
	fact_search_menu = %FactsSearchMenu
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
	value_a_numeric_text_edit.connect("text_submitted", _on_value_a_numeric_text_submitted)
	value_b_text_edit.connect("text_submitted", _on_value_b_text_submitted)
	
	
	current_database = database
	current_rule = rule
	criteria_index = index
	criteria_object = criteria
	
	label_input.text = criteria_object.label
	
	if criteria.fact:
		fact_search_menu.search_input_text = criteria.fact.label
	
	fact_search_menu.items_list = current_database.global_facts.values()
	
	negate_check.button_pressed = criteria.is_reverse
	
	update_operation_menu_items()
	update_values_input()
	
	if is_new_criteria:
		operation_menu.text = "Select operation"
	

func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_criteria_button):
		remove_criteria_button.icon = get_theme_icon("Remove", "EditorIcons")


func _set_criteria_property(property_name: StringName, value: Variant) -> void:
	criteria_object.set(property_name, value)
	current_database.save_data()


### Signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_facts_search_menu_item_selected(item):
	operation_menu.text = "Select operation"
	enum_values_menu.text = "Select value"
	_set_criteria_property("fact", fact_search_menu.current_item)
	update_operation_menu_items()
	update_values_input()


func _on_label_line_edit_text_submitted(new_text):
	_set_criteria_property("label", new_text)


func _on_remove_criteria_button_pressed():
	current_rule.remove_criteria_by_index(criteria_index)
	current_database.save_data()
	queue_free()
	
	
func _on_value_a_numeric_text_submitted(new_text: String) -> void:
	_set_criteria_property("value_a", int(new_text))
	value_a_numeric_text_edit.release_focus()
	
	
func _on_value_b_text_submitted(new_text: String) -> void:
	_set_criteria_property("value_b", int(new_text))
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
