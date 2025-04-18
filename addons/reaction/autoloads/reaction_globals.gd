@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export var default_database: ReactionDatabase

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

enum ItemsTypesEnum {
	BASE,
	FACT, 
	EVENT, 
	RULE, 
	CRITERIA,
	MODIFICATION,
	FUNC_CRITERIA, 
	FUNC_CRIT_OPERATION, 
	RESPONSE_GROUP, 
	RESPONSE,
	DIALOG,
	DIALOG_TEXT,
	CHOICE
}

## ------------------globals contexts ----------------------------------------------
## add here your global context variables

@onready var global_context: ReactionBlackboard = _get_init_global_blackboard()


func _get_init_global_blackboard() -> ReactionBlackboard:
	var new_global_context = ReactionBlackboard.new()
	new_global_context.label = "global_context"
	return new_global_context
	
## ---------------------------------------------------------------------------------

func _ready():
	default_database = get_default_database()
	
	
func save_all_contexts_data():
	global_context.save_data()
	## add below extra custom added context to save their data too
		
		
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
		
		
func _change_reaction_ui_debug_visibility() -> void:
	var nodes = get_tree().get_nodes_in_group("reaction_debug_ui")
	for node in nodes:
		node.visible = not node.visible
		

## ----------------------------------------------------------------------------[br]
## private fuction to sort rules when have priority higher than 0 [br]
## ----------------------------------------------------------------------------
func _sort_priority_rules(a, b):
	if a.priority < b.priority:
		return true

	if a.priority == b.priority:
		return a.get_criterias_count() > b.get_criterias_count()

	return false
	

## ----------------------------------------------------------------------------[br]
## global fuction to sort rules [br]
## ----------------------------------------------------------------------------
func sort_rules(rules_array: Array[ReactionRuleItem]) -> Array[ReactionRuleItem]:
	var new_rules: Array[ReactionRuleItem] = []
	var temp_priority_rules: Array[ReactionRuleItem] = []
	var temp_non_priority_rules: Array[ReactionRuleItem] = []

	for rule in rules_array:
		if rule and rule.priority > 0:
			temp_priority_rules.append(rule)
		else:
			temp_non_priority_rules.append(rule)

	temp_priority_rules.sort_custom(_sort_priority_rules)

	temp_non_priority_rules.sort_custom(
		func(a, b): return a.get_criterias_count() > b.get_criterias_count()
	)

	new_rules.append_array(temp_priority_rules)
	new_rules.append_array(temp_non_priority_rules)

	return new_rules
	
	
func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("reaction_ui_debug"):
			_change_reaction_ui_debug_visibility()
