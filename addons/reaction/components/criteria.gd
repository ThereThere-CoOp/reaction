@tool
extends HBoxContainer

@onready var remove_criteria_button: Button = %RemoveCriteriaButton

func _ready():
	call_deferred("apply_theme")


func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_criteria_button):
		remove_criteria_button.icon = get_theme_icon("Remove", "EditorIcons")


func _on_main_view_theme_changed() -> void:
	apply_theme()
