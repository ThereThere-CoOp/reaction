@tool
extends HBoxContainer

var current_database: ReactionDatabase

var criteria_index: int = -1

var criteria_object : ReactionRuleCriteria

@onready var remove_criteria_button: Button = %RemoveCriteriaButton

# input components
@onready var label_input: LineEdit = %LabelLineEdit
@onready var fact_search_menu: HBoxContainer = %FactsSearchMenu
@onready var operation_menu: MenuButton = %OperationMenuButton
@onready var value_a_input: LineEdit = %ValueALineEdit
@onready var enum_values_menu: MenuButton = %EnumValuesMenuButton
@onready var value_b_label: Label = %ValueBLabel
@onready var value_b_input: LineEdit = %ValueBLineEdit
@onready var boolean_value_check: CheckBox = %BooleanValueCheckBox
@onready var negate_check: CheckButton = %NegateCheckButton


func _ready():
	call_deferred("apply_theme")
	value_b_input.visible = false
	value_b_label.visible = false
	boolean_value_check.visible = false
	enum_values_menu.visible = false


func update_operation_menu_items() -> void:
	var operation_menu_labels : Array[String]
	var menu: PopupMenu = operation_menu.get_popup()
	
	if criteria_object.fact.type == TYPE_INT:
		operation_menu_labels = ["=", "<", ">", "a<=x<=b"]
	else:
		operation_menu_labels = ["="]
	
	for operation in operation_menu_labels:
		menu.add_item(operation)
		
	operation_menu.text = criteria_object.operation


func update_values_input() -> void:
	value_a_input.visible = true
	
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
		
	update_operation_menu_items()
	update_values_input()
	
			
func setup(criteria: ReactionRuleCriteria, index: int) -> void:
	criteria_index = index
	criteria_object = criteria
	
	label_input.text = criteria_object.label
	fact_search_menu.search_input.text = criteria.fact.label
	value_a_input.text = criteria.value_a
	value_b_input.text = criteria.value_b
	negate_check.button_pressed = criteria.is_reverse
	

func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_criteria_button):
		remove_criteria_button.icon = get_theme_icon("Remove", "EditorIcons")


### Signals


func _on_main_view_theme_changed() -> void:
	apply_theme()
