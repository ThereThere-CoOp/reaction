@tool
class_name ReactionUtilities
extends Node

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
static func get_function_result(function: String, context: ReactionBlackboard, check_only: bool = false):
	var expr = Expression.new()
	
	var function_array = function.split(";")
	var formated_function = ""
	var index = 0
	
	for operator in function_array:
		if not ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.has(operator) and not operator.is_valid_float():
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
			
			if operator == ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("pow", "") or operator == ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("sqrt", ""):
				var index_minus_one = index - 1
				if index != 0 and not (ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("+", "") == function_array[index_minus_one] or ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("-", "") == function_array[index_minus_one] or ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("*", "") == function_array[index_minus_one] or ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("/", "") == function_array[index_minus_one]):
					return null
		
		index += 1
		
		
	var parse_result = expr.parse(formated_function)
	if parse_result == OK:
		var result = expr.execute()
		return result
	else:
		return null
		

## ----------------------------------------------------------------------------[br]
## Private fuction to sort rules when have priority higher than 0 [br]
## ----------------------------------------------------------------------------
static func _sort_priority_rules(a, b):
	if a.priority < b.priority:
		return true

	if a.priority == b.priority:
		return a.get_criterias_count() > b.get_criterias_count()

	return false
	

## ----------------------------------------------------------------------------[br]
## global fuction to sort rules [br]
## ----------------------------------------------------------------------------
static func sort_rules(rules_array: Array[ReactionRuleItem]) -> Array[ReactionRuleItem]:
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
static func generate_sqlite_query_placeholders_from_array(array):
	var arr := Array()
	arr.resize(len(array))
	arr.fill("?")
	var placeholders = ",".join(arr)
	
	return placeholders
	

## ----------------------------------------------------------------------------[br]
## Remove sqlite database file from the file system [br]
## ----------------------------------------------------------------------------
static func remove_sqlite_database(database: SQLite) -> void:
	var file_path = database.path
	database.close_db()

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		
		
static func remove_all_children(parent) -> void:
	for child in parent.get_children():
		child.queue_free()
		
		
static func get_response_object_from_reaction_type(type: int):
	return ReactionResponseGroupItem.get_new_object() if type == ReactionConstants.ITEMS_TYPE_ENUM.RESPONSE_GROUP else ReactionResponseDialogItem.get_new_object() 
