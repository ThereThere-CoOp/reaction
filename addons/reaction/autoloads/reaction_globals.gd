@tool
extends Node

var databases: Dictionary = {}

var current_sqlite_database: SQLite

@export var default_database: ReactionDatabase

## ------------------globals contexts ------------------------------------------------------
## add here your global context variables

@onready var global_context: ReactionBlackboard = _get_init_global_blackboard()


func _get_init_global_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "global_context"
	return new_global_context
	
## ------------------------------------------------------------------------------------------

## ---------------------- execution control -------------------------------------------------
## each key of the field is the uid of a response group
## and the values are a dictionary to store the current executed responses and
## where each key is an response uid
@export var responses_groups_executed_responses = {}

## each key of the field is the uid of a response group and the values are the
## current index to cycle through when return method is by exection order (by default each
## value is zero.
@export var responses_groups_order_current_index = {}


func add_executed_response(response_group_uid: String, response_uid: String) -> void:
	if response_group_uid in responses_groups_executed_responses:
		responses_groups_executed_responses[response_group_uid][response_uid] = true
	else:
		responses_groups_executed_responses[response_group_uid] = {}
		responses_groups_executed_responses[response_group_uid][response_uid] = true
		
		
func get_response_group_execution_dict(response_group_uid: String) -> Dictionary:
	return responses_groups_executed_responses.get(response_group_uid, {})
		
		
func update_responses_groups_order_current_index(response_group_uid: String, index: int) -> void:
	responses_groups_order_current_index[response_group_uid] = index
	

func get_response_group_order_current_index(response_group_uid: String) -> int:
	return responses_groups_order_current_index.get(response_group_uid, 0)
	
	
func clear_responses_groups_execution() -> void:
	responses_groups_executed_responses.clear()
	
	
func clear_responses_groups_execution_index() -> void:
	responses_groups_order_current_index.clear()
	
		
## --------------------------------------------------------------------------------------------

func _ready():
	default_database = get_default_database()
	
	
## ----------------------------------------------------------------------------[br]
## Use to save on the file system the current contexts data [br]
## ----------------------------------------------------------------------------
func save_all_contexts_data():
	global_context.save_data()
	## add below extra custom added context to save their data too
		

## ----------------------------------------------------------------------------[br]
## Get default rection resource item database to be used in-game [br]
## ----------------------------------------------------------------------------
func get_default_database() -> ReactionDatabase:
	var default_database_path = ReactionSettings.get_setting(
		ReactionSettings.DEFAULT_RESOURCE_DATABASE_PATH_SETTING_NAME, 
		"")
		
	if FileAccess.file_exists(default_database_path):
		return ResourceLoader.load(default_database_path, "", ResourceLoader.CACHE_MODE_REPLACE).duplicate(true)
		
	return null
		
		
func _change_reaction_ui_debug_visibility() -> void:
	var nodes = get_tree().get_nodes_in_group("reaction_debug_ui")
	for node in nodes:
		node.visible = not node.visible
	
	
func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("reaction_ui_debug"):
			_change_reaction_ui_debug_visibility()
