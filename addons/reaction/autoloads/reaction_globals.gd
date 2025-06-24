@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

var current_sqlite_database: SQLite

@export var default_database: ReactionDatabase

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

const CRITERIA_FUNCTION_OPERATOR_OPTIONS = {
	"+": "+",
	"-": "-",
	"*": "*",
	"/": "/",
	"(": "(",
	")": ")"
}

enum ItemsTypesEnum {
	BASE,
	FACT, 
	EVENT, 
	RULE, 
	CRITERIA,
	MODIFICATION,
	FUNC_CRITERIA, 
	RESPONSE_GROUP, 
	RESPONSE,
	DIALOG,
	DIALOG_TEXT,
	CHOICE,
	TAG,
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
## Calcule the result of the function in dependency of the select facts and 
## function [br]
## [b]Parameter(s):[/b] [br]
## [b]* function | String:[/b] A ";" separated math expression 
## [b]* context | ReactionBlackboard:[/b] Current blackboard fact values 
## [b]* check_only | bool:[/b] If true only check the validity of the math expression
## [br]
## [b]Returns: int[/b] [br]
## The result of the execution of the function or null is the function is not valid [br]
## ----------------------------------------------------------------------------
func get_function_result(function: String, context: ReactionBlackboard, check_only: bool = false):
	var expr = Expression.new()
	
	var function_array = function.split(";")
	var formated_function = ""
	formated_function.join(function_array)
	var facts = {}
	
	for operator in function_array:
		if not CRITERIA_FUNCTION_OPERATOR_OPTIONS.has(operator) and not operator.is_valid_float():
			if not check_only:
				var fact_value = context.get_blackboard_fact(operator)
				if fact_value:
					facts[operator] = fact_value.value
				else:
					facts[operator] = 0
			else:
				facts[operator] = 1
	
	var parse_result = expr.parse(formated_function, facts.keys())
	if parse_result == OK:
		var result = expr.execute(facts.values().map(func(fact_value): return fact_value))
		return result
	else:
		return null
		

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
	

func remove_sqlite_database(database: SQLite) -> void:
	var file_path = database.path
	database.close_db()

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	
	
func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("reaction_ui_debug"):
			_change_reaction_ui_debug_visibility()
