@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

var current_sqlite_database: SQLite

@export var default_database: ReactionDatabase

@export var responses_types: Dictionary = { "Dialog": "Dialog" }

const CRITERIA_FUNCTION_OPERATOR_OPTIONS = {
	"+": "+",
	"-": "-",
	"*": "*",
	"/": "/",
	"(": "(",
	")": ")",
	"pow": "pow",
	"sqrt": "sqrt",
	",": ",",
}
const RANDOM_WEIGHT_RETURN_METHOD = 'random_weight'
const RANDOM_RETURN_METHOD = 'random'
const EXECUTION_ORDER_RETURN_METHOD = 'by_order'


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
		ReactionSettings.DEFAULT_DATABASE_PATH_SETTING_NAME, 
		"")
		
	if FileAccess.file_exists(default_database_path):
		return ResourceLoader.load(default_database_path)
		
	return null
	

func get_response_object_from_reaction_type(type: int):
	return ReactionResponseGroupItem.get_new_object() if type == ItemsTypesEnum.RESPONSE_GROUP else ReactionResponseDialogItem.get_new_object() 
		
		
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
## The result of the execution of the function or null is the function is [br] 
## not valid 
## ----------------------------------------------------------------------------
func get_function_result(function: String, context: ReactionBlackboard, check_only: bool = false):
	var expr = Expression.new()
	
	var function_array = function.split(";")
	var formated_function = ""
	
	for operator in function_array:
		if not CRITERIA_FUNCTION_OPERATOR_OPTIONS.has(operator) and not operator.is_valid_float():
			if not check_only:
				var fact_value = context.get_blackboard_fact(operator)
				if fact_value:
					formated_function += str(fact_value.value)
				else:
					formated_function += str(0)
			else:
				formated_function += str(1)
		else:
			formated_function += operator
	
	var parse_result = expr.parse(formated_function)
	if parse_result == OK:
		var result = expr.execute()
		return result
	else:
		return null
		

## ----------------------------------------------------------------------------[br]
## Private fuction to sort rules when have priority higher than 0 [br]
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
	

## ----------------------------------------------------------------------------[br]
## Generate placeholder to query sqlite database table by an array of ids [br]
## [b]Parameter(s):[/b] [br]
## [b]* array | Array:[/b] An array of sqlite database table ids [br]
## [b]Returns: String[/b] [br]
## The string with placeholder to be used on the database query [br] 
## ----------------------------------------------------------------------------
func generate_sqlite_query_placeholders_from_array(array):
	var arr := Array()
	arr.resize(len(array))
	arr.fill("?")
	var placeholders = ",".join(arr)
	
	return placeholders
	

## ----------------------------------------------------------------------------[br]
## Remove sqlite database file from the file system [br]
## ----------------------------------------------------------------------------
func remove_sqlite_database(database: SQLite) -> void:
	var file_path = database.path
	database.close_db()

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		
		
func remove_all_children(parent) -> void:
	for child in parent.get_children():
		child.queue_free()
	
	
func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("reaction_ui_debug"):
			_change_reaction_ui_debug_visibility()
