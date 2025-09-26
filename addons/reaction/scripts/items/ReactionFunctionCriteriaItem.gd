@tool
class_name ReactionFunctionCriteriaItem
extends ReactionCriteriaItem
## ----------------------------------------------------------------------------[br]
## Resource to storage a rule criteria with a function.
##
## A rule criteria checks if a given fact value meets a condition. Is used
## to test if a rule match for a context data in a given time. [br]
## ----------------------------------------------------------------------------

## A string of ";" separated operators and facts uid to be calculated on execution time
@export var function: String = ""


func get_function_result(context) -> int:
	return int(ReactionGlobals.get_function_result(function, context))
## ----------------------------------------------------------------------------[br]
## Tests if the criteria match with a blackboard fact [br]
## [b]Parameter(s):[/b] [br]
## [b]* blackboard_fact | [ReactionBlackboardFact]:[/b] Blackboard fact value to
## test with the criteria [br]
## [b]Returns: bool[/b] [br]
## Returns true if criteria match with fact value  [br]
## ----------------------------------------------------------------------------
func test(context: ReactionBlackboard) -> bool:
	
	var result: int = get_function_result(context)
	
	if result == null:
		return false
	
	var criteria_test_result = (
		result >= _internal_value_a
		and result <= _internal_value_b
	)	
	return criteria_test_result if not is_reverse else not criteria_test_result
	
	
static func get_new_object():
	return ReactionFunctionCriteriaItem.new()
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.FUNC_CRITERIA
