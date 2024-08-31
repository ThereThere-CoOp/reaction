@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export var default_database: ReactionDatabase

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

## ------------------globals contexts ----------------------------------------------
## add here your global context variables

@onready var global_context: ReactionBlackboard = _get_init_global_blackboard()


func _get_init_global_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "global_context"
	return new_global_context
	
@onready var consumables_inventory_context: ReactionBlackboard = _get_init_consumables_inventory_blackboard()


func _get_init_consumables_inventory_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "consumables_inventory_context"
	return new_global_context
	
	
@onready var equipments_inventory_context: ReactionBlackboard = _get_init_equipments_inventory_blackboard()


func _get_init_equipments_inventory_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "equipments_inventory_context"
	return new_global_context


@onready var goods_inventory_context: ReactionBlackboard = _get_init_goods_inventory_blackboard()


func _get_init_goods_inventory_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "goods_inventory_context"
	return new_global_context
	
## ---------------------------------------------------------------------------------

func _ready():
	default_database = get_default_database()
	
		
func _change_reaction_ui_debug_visibility() -> void:
	var nodes = get_tree().get_nodes_in_group("reaction_debug_ui")
	for node in nodes:
		node.visible = not node.visible
		
		
func get_default_database() -> ReactionDatabase:
	var default_database_path = ReactionSettings.get_setting(
		ReactionSettings.DEFAULT_DATABASE_PATH_SETTING_NAME, 
		"")
		
	if FileAccess.file_exists(default_database_path):
		return ResourceLoader.load(default_database_path)
		
	return null
	
	
func get_item_type(item: Resource) -> String:
	if item is ReactionEventItem:
		return "Event"
	elif item is ReactionFactItem:
		return "Fact"
	elif item is ReactionRuleItem:
		return "Rule"
	elif item is ReactionCriteriaItem:
		return "Criteria"
	elif item is ReactionContextModificationItem:
		return "Modification"
	elif item is ReactionResponseGroupItem:
		return "Response Group"
	elif item is ReactionResponseDialogItem:
		return responses_types["Dialog"]
	elif item is ReactionResponseItem:
		return "Response"
	else:
		return "Fact"
		
		
func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("reaction_ui_debug"):
			_change_reaction_ui_debug_visibility()
