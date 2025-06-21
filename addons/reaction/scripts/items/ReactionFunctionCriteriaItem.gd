@tool
class_name ReactionFunctionCriteriaItem
extends ReactionCriteriaItem
## ----------------------------------------------------------------------------[br]
## Resource to storage a rule criteria with a function.
##
## A rule criteria checks if a given fact value meets a condition. Is used
## to test if a rule match for a context data in a given time. [br]
## ----------------------------------------------------------------------------
	
@export var operations: Array[ReactionCriteriaFunctionOperationItem] = []

# @export_enum("+", "-", "*") var function: String


func _calculate_with_operation(total: int, value: int, operation: String) -> int:
	match operation:
		"+":
			return total + value
		"-":
			return total - value
		"*":
			return total * value
		"/":
			return total / value
		_:
			return total + value
			
			
func add_fact(function_operation: ReactionCriteriaFunctionOperationItem) -> void:
	operations.append(function_operation)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a fact from the criteria using the index [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the fact to remove [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_fact_by_index(index: int) -> void:
	operations[index].remove_fact_reference_log(operations[index])
	operations.remove_at(index)


## ----------------------------------------------------------------------------[br]
## Calcule the result of the function in dependency of the select facts and 
## function [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | ReactionBlackboard:[/b] Current blackboard fact values 
## [br]
## [b]Returns: int[/b] [br]
## The result of the execution of the function  [br]
## ----------------------------------------------------------------------------
func get_function_result(context: ReactionBlackboard) -> int:
	var total_value: int = 0
	if operations.size() > 0:
		var first_operation_fact: ReactionFactItem = operations[0].fact
		var first_b_fact = context.get_blackboard_fact(first_operation_fact.uid)
		
		# if fact value is null or not int the value is ZERO
		if first_b_fact and first_operation_fact.type == TYPE_INT:
			total_value = first_b_fact.value
		
		for index: int in range(1, operations.size()):
			var b_operation_fact: ReactionFactItem = operations[index].fact
			var current_operation: String = operations[index].operation
			var temp_b_fact: ReactionBlackboardFact = context.get_blackboard_fact(b_operation_fact.uid)
			
			var current_value: int = 0
			# if fact value is null or not int the value is ZERO
			if temp_b_fact and b_operation_fact.type == TYPE_INT:
				current_value = temp_b_fact.value
				
			total_value = _calculate_with_operation(total_value, current_value, current_operation)
		
	return total_value
	
	
## ----------------------------------------------------------------------------[br]
## Tests if the criteria match with a blackboard fact [br]
## [b]Parameter(s):[/b] [br]
## [b]* blackboard_fact | [ReactionBlackboardFact]:[/b] Blackboard fact value to
## test with the criteria [br]
## [b]Returns: bool[/b] [br]
## Returns true if criteria match with fact value  [br]
## ----------------------------------------------------------------------------
func test(context: ReactionBlackboard) -> bool:
	
	var total_value: int = get_function_result(context)
	
	var criteria_test_result = (
		total_value >= _internal_value_a
		and total_value <= _internal_value_b
	)
	
	return criteria_test_result if not is_reverse else not criteria_test_result
	
	
static func get_new_object():
	return ReactionFunctionCriteriaItem.new()
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.FUNC_CRITERIA
