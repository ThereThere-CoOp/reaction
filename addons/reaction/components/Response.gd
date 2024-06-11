@tool
class_name ResponseComponent
extends HBoxContainer

@onready var remove_response_button: Button = %RemoveResponseButon


func setup(response: ReactionResponseBaseItem) -> void:
	pass
	
	
func _ready():
	call_deferred("apply_theme")
	
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_response_button):
		remove_response_button.icon = get_theme_icon("Remove", "EditorIcons")
