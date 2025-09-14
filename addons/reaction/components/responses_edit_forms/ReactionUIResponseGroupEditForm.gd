@tool
class_name ReactionUIResponseGroupEditForm
extends ReactionUIMainResponseEditForm


@onready var responses_config_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn")

var responses_config_container: VBoxContainer

func setup(response: ReactionResponseBaseItem) -> void:
	super(response)
	
	responses_config_container = %ResponsesConfigContainer
	
	if response:
		responses_config_form_scene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn") 
		var config_where = "parent_group_id = %d" % response.sqlite_id
		var responses_data = sqlite_database.select_rows("response_parent_group_rel", config_where, ["*"])
		
		for data in responses_data:
			var response_config: ReactionUIResponseGroupResponseConfig = responses_config_form_scene.instantiate()
			response_config.setup(response, data)
			responses_config_container.add_child(response_config)
	
