@tool
extends HBoxContainer

var current_database: ReactionDatabase

var current_rule: ReactionRuleItem

var criteria_index: int = -1

var criteria_object : ReactionRuleCriteria

@onready var remove_criteria_button: Button = %RemoveCriteriaButton

var label_input: LineEdit
var fact_search_menu: HBoxContainer
var operation_menu: MenuButton
var value_a_input: LineEdit
var enum_values_menu: MenuButton
var value_b_label: Label
var value_b_input: LineEdit
var boolean_value_check: CheckBox
var negate_check: CheckButton


func _ready():
	call_deferred("apply_theme")


func update_operation_menu_items() -> void:
	var operation_menu_labels : Array[String]
	var menu: PopupMenu = operation_menu.get_popup()
	
	if not criteria_object.fact:
		operation_menu_labels = []
	elif criteria_object.fact.type == TYPE_INT:
		operation_menu_labels = ["=", "<", ">", "a<=x<=b"]
	else:
		operation_menu_labels = ["="]
	
	for operation in operation_menu_labels:
		menu.add_item(operation)
		
	operation_menu.text = criteria_object.operation


func update_values_input() -> void:
	value_a_input.visible = true
	
	if criteria_object.fact:
		if criteria_object.fact.type == TYPE_STRING and criteria_object.fact.is_enum:
			value_a_input.visible = false
			value_b_input.visible = false
			value_b_label.visible = false
			enum_values_menu.visible = true
			 
			var enum_menu = enum_values_menu.get_popup()
			var values = criteria_object.fact.enum_names
			for value in values:
				enum_menu.add_item(value)
				
			enum_values_menu.text = criteria_object.value_a
		
	if criteria_object.operation == "a<=x<=b":
		value_b_input.visible = true
		value_b_label.visible = true


func setup(database: ReactionDatabase, rule: ReactionRuleItem, criteria: ReactionRuleCriteria, index: int, is_new_criteria: bool = false) -> void:
	label_input = %LabelLineEdit
	fact_search_menu = %FactsSearchMenu
	operation_menu = %OperationMenuButton
	value_a_input = %ValueALineEdit
	enum_values_menu = %EnumValuesMenuButton
	value_b_label = %ValueBLabel
	value_b_input = %ValueBLineEdit
	boolean_value_check = %BooleanValueCheckBox
	negate_check = %NegateCheckButton

	value_b_input.visible = false
	value_b_label.visible = false
	boolean_value_check.visible = false
	enum_values_menu.visible = false
	
	current_database = database
	current_rule = rule
	criteria_index = index
	criteria_object = criteria
	
	label_input.text = criteria_object.label
	
	if criteria.fact:
		fact_search_menu.search_input.text = criteria.fact.label
		
	fact_search_menu.items_list = current_database.global_facts.values()
	
	value_a_input.text = criteria.value_a
	value_b_input.text = criteria.value_b
	
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
	update_operation_menu_items()
	update_values_input()
	operation_menu.text = "Select operation"
	enum_values_menu.text = "Select value"
	_set_criteria_property("fact", fact_search_menu.current_item)


func _on_label_line_edit_text_submitted(new_text):
	_set_criteria_property("label", new_text)


func _on_remove_criteria_button_pressed():
	current_rule.remove_criteria_by_index(criteria_index)
	queue_free()
