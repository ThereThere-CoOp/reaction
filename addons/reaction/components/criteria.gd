@tool
extends HBoxContainer

var criteria_index: int = -1

var criteria_object : ReactionRuleCriteria

@onready var remove_criteria_button: Button = %RemoveCriteriaButton

# input components
@onready var label_input: LineEdit = %LabelLineEdit
@onready var operation_menu: MenuButton = %OperationMenuButton
@onready var value_a_input: LineEdit = %ValueALineEdit
@onready var value_b_input: LineEdit = %ValueBLineEdit
@onready var boolean_value_check: CheckBox = %BooleanValueCheckBox
@onready var negate_check: CheckButton = %NegateCheckButton


func _ready():
	call_deferred("apply_theme")
	
	
func setup(criteria: ReactionRuleCriteria, index: int) -> void:
	criteria_index = index
	criteria_object = criteria
	
	label_input.text = criteria_object.label
	operation_menu.text = criteria.operation
	

func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_criteria_button):
		remove_criteria_button.icon = get_theme_icon("Remove", "EditorIcons")


func _on_main_view_theme_changed() -> void:
	apply_theme()
