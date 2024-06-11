@tool
class_name ResponseGroup
extends MarginContainer

var current_database: ReactionDatabase

var response_group_object: Resource

@onready var response_group_scene: PackedScene = preload("res://addons/reaction/components/ResponseGroup.tscn")
@onready var response_component_scene: PackedScene = preload("res://addons/reaction/components/ResponseComponent.tscn")

@onready var add_response_menu : MenuButton = %AddResponsesMenuButton
@onready var show_hide_responses_button : CheckButton = %ShowHideResponsesButton
@onready var responses_container : VBoxContainer = %ResponsesContainer
@onready var responses_scroll_container : ScrollContainer = %ResponsesScrollContainer
@onready var _responses_scrollbar: VScrollBar = responses_scroll_container.get_v_scroll_bar()

var _responses_scroll_to_end = false

func _ready():
	_responses_scrollbar.changed.connect(_on_responses_scroll_changed)
	ReactionSignals.database_selected.connect(_on_database_selected)
	
	var responses_menu_popup = add_response_menu.get_popup()
	responses_menu_popup.clear()
	for response_type in ReactionGlobals.responses_types:
		responses_menu_popup.add_item(response_type)
		
		
func setup(database: ReactionDatabase, response_group: ReactionResponseGroupItem) -> void:
	current_database = database
	response_group_object = response_group
	
	var index = 0
	for response in response_group_object.responses.values():
		var new_response_component_scene = response_component_scene.instantiate()
		
		if response is ReactionResponseGroupItem:
			var new_response_group = response_group_scene.instantiate()
			new_response_group.setup(current_database, response)
			new_response_component_scene.setup(current_database, response, response_group_object, index, new_response_group)
			
		if response is ReactionResponseItem:
			new_response_component_scene.setup(response, response_group_object, index)
		
		responses_container.add_child(new_response_component_scene)
		index += 1
	
	
### signals


func _on_database_selected(database: ReactionDatabase) -> void:
	current_database = database


func _on_responses_scroll_changed() -> void:
	if _responses_scroll_to_end:
		responses_scroll_container.set_v_scroll(int(_responses_scrollbar.max_value))
		

func _on_show_hide_responses_button_toggled(toggled_on):
	responses_scroll_container.visible = toggled_on
