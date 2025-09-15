@tool
class_name ReactionUIResponseGroupEditForm
extends ReactionUIMainResponseEditForm


# @onready var responses_config_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn")
var responses_config_form_scene: PackedScene

var responses_config_list_container: VBoxContainer

func setup(response: ReactionResponseBaseItem) -> void:
	super(response)
	
	responses_config_list_container = %ConfigsListContainer
	
	if response:
		responses_config_form_scene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn") 
		
		var responses_data = response.get_sqlite_children_list(null, false)
		
		for data in responses_data:
			var response_config: ReactionUIResponseGroupResponseConfig = responses_config_form_scene.instantiate()
			response_config.setup(response, data)
			responses_config_list_container.add_child(response_config)
	
