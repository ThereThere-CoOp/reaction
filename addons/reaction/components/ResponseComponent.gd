@tool
class_name ResponseComponent
extends HBoxContainer

var current_database: ReactionDatabase

var index: int = -1

var response_object : ReactionResponseBaseItem

var current_parent_object: ReactionResponseGroupItem

var current_response_group_scene: ResponseGroup

@onready var index_label : Label = %IndexLabel
@onready var response_container : MarginContainer = %ResponseContainer
@onready var response_button : Button = %ResponseButton
@onready var remove_response_button: Button = %RemoveResponseButon


# call it before add to the scene
func setup(database: ReactionDatabase, response: ReactionResponseBaseItem, parent_object: ReactionResponseGroupItem, new_index: int, response_group_scene: ResponseGroup = null) -> void:
	current_database = database
	response_object = response
	current_parent_object = parent_object
	index = new_index
	current_response_group_scene = response_group_scene
	
	
func _ready():
	call_deferred("apply_theme")
	
	index_label.text = "#%s:" % (index + 1)
	
	if response_object:
		if response_object is ReactionResponseGroupItem:
			response_button.visible = false
			response_container.add_child(current_response_group_scene)
		else:
			response_button.visible = true
			response_button.text = response_object.label
		
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_response_button):
		remove_response_button.icon = get_theme_icon("Remove", "EditorIcons")
