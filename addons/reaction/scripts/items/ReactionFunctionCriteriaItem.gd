@tool
class_name ReactionFunctionCriteriaItem
extends ReactionCriteriaItem
## ----------------------------------------------------------------------------[br]
## Resource to storage a rule criteria with a function.
##
## A rule criteria checks if a given fact value meets a condition. Is used
## to test if a rule match for a context data in a given time. [br]
## ----------------------------------------------------------------------------

@export var facts: Array[ReactionCriteriaFunctionFactItem] = []

@export_enum("+", "-", "*") var function: String


func _calculate_with_function(total: int, value: int) -> int:
	match function:
		"+":
			return total + value
		"-":
			return total - value
		"*":
			return total * value
		_:
			return total + value
			
			
func add_fact(function_fact: ReactionCriteriaFunctionFactItem) -> void:
	facts.append(function_fact)


func get_function_result(context: ReactionBlackboard) -> int:
	var total_value: int = 0
	if facts.size() > 0:
		var first_b_fact = context.get_blackboard_fact(facts[0].fact.uid)
		
		if first_b_fact:
			total_value = first_b_fact.value
		
		for index: int in range(1, facts.size()):
			var temp_b_fact: ReactionBlackboardFact = context.get_blackboard_fact(facts[index].fact.uid)
			
			var current_value: int = 0
			if temp_b_fact:
				current_value = temp_b_fact.value
				
			total_value = _calculate_with_function(total_value, current_value)
		
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
	
	
func get_new_object() -> ReactionFunctionCriteriaItem:
	return ReactionFunctionCriteriaItem.new()
