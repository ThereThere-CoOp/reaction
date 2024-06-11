@tool
class_name ResponseComponent
extends HBoxContainer

var index: int = -1

var response_object : ReactionResponseBaseItem

var current_parent_object: Resource

@onready var index_label : Label = %IndexLabel
@onready var response_container : MarginContainer = %ResponseContainer
@onready var response_button : Button = %ResponseButton
@onready var remove_response_button: Button = %RemoveResponseButon


# call it before add to the scene
func setup(response: ReactionResponseBaseItem, parent_object: Resource, new_index: int) -> void:
	response_object = response
	current_parent_object = parent_object
	index = new_index
	
	
func _ready():
	call_deferred("apply_theme")
	
	index_label.text = "#%s:" % (index + 1)
	
	if response_object is ReactionResponseGroupItem:
		response_button.visible = false
	else:
		response_button.visible = true
		response_button.text = response_object.label
		
	
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_response_button):
		remove_response_button.icon = get_theme_icon("Remove", "EditorIcons")
