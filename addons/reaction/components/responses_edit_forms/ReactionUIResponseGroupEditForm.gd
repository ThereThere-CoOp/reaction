@tool
class_name ReactionUIResponseGroupEditForm
extends ReactionUIMainResponseEditForm


# @onready var responses_config_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn")
var responses_config_form_scene: PackedScene

var responses_config_list_container: VBoxContainer

var return_method_menu_button: MenuButton

var return_method_menu_text_options: Dictionary = {
	"order": "By order", "random": "Random", "random_weight": "Random with weight"
}

func setup(response: ReactionResponseBaseItem) -> void:
	super(response)
	
	responses_config_list_container = %ConfigsListContainer
	return_method_menu_button = %ReturnMethodMenuButton
	
	var return_menu: PopupMenu = return_method_menu_button.get_popup()
	return_menu.index_pressed.connect(_on_return_method_menu_index_pressed)
	return_menu.clear()

	var return_method_text_options_values = return_method_menu_text_options.values()
	for i in range(return_method_text_options_values.size()):
		return_menu.add_item(return_method_text_options_values[i], i)
	
	var return_method = response.return_method 
	if return_method:
		return_method_menu_button.text = return_method_menu_text_options[return_method]
	else:
		return_method_menu_button.text = ''
		
	if response:
		responses_config_form_scene = preload("res://addons/reaction/components/responses_edit_forms/responses_groups_components/ReactionUIResponseGroupResponseConfig.tscn") 
		
		var responses_data = response.get_sqlite_children_list(null, false)
		
		for data in responses_data:
			var response_config: ReactionUIResponseGroupResponseConfig = responses_config_form_scene.instantiate()
			response_config.setup(response, data)
			responses_config_list_container.add_child(response_config)
			
			
func _on_return_method_menu_index_pressed(index):
	var popup = return_method_menu_button.get_popup()
	var label = popup.get_item_text(index)
	
	var return_method = ""
	if return_method_menu_text_options["order"] == label:
		return_method = "order"
	if return_method_menu_text_options["random"] == label:
		return_method = "random"
	if return_method_menu_text_options["random_weight"] == label:
		return_method = "random_weight"
	
	return_method_menu_button.text = return_method_menu_text_options[return_method]
	current_response.return_method = return_method
	current_response.update_sqlite()
	
	for response_config_panel in responses_config_list_container.get_children():
		response_config_panel.change_inputs_visibility(current_response)
	
	
