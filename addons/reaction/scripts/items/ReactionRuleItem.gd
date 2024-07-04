@tool
class_name ReactionRuleItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a reaction rule.
##
## A rule contains a list of criteria and at least a response group
## (a ReactionResponseGroupItem). When the criterias are met the rule
## responses are returned. [br]
## ----------------------------------------------------------------------------

## rules criterias
@export var criterias: Array[ReactionCriteriaItem]

## rules context modifications
@export var modifications: Array[ReactionContextModificationItem]

## specify if the rule need to match only once
@export var match_once := false

## the rules with priority higher than 0 will be ordered first
## from higher priority to lower, if priority is cero
## rule is ordered by number of rules
@export var priority: int = 0

## rule group of responses
@export var responses: ReactionResponseGroupItem


## Returns the length of the rule criterias array
func get_criterias_count() -> int:
	return len(criterias)


## ----------------------------------------------------------------------------[br]
## Return true if the rule criterias match with the blackboard context
## passed as parameter, false if not [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if rule
## match with facts data [br]
## [b]Returns: bool[/b] [br]
## Returns true if rule matchs with the context  [br]
## ----------------------------------------------------------------------------
func test(context: ReactionBlackboard) -> bool:
	for criteria in criterias:
		var current_bfact = context.get_blackboard_fact(criteria.fact.uid)

		# if criteria fact do not exists on blackboard
		# rule do not match
		if current_bfact == null:
			return false

		if not criteria.test(current_bfact):
			return false

	return true


## ----------------------------------------------------------------------------[br]
## Executes all the modifications of the rules on the context [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Context were the modifictions
## will be applied [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func execute_modifications(context: ReactionBlackboard) -> void:
	for modification in modifications:
		modification.execute(context)
		

## ----------------------------------------------------------------------------[br]
## Add a criteria to the rule [br]
## [b]Parameter(s):[/b] [br]
## [b]* criteria | ReactionCriteriaItem:[/b] Criteria to add to the rule [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_criteria(criteria: ReactionCriteriaItem) -> void:
	criterias.append(criteria)


## ----------------------------------------------------------------------------[br]
## Remove a criteria from the rule using the index [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the criteria to remove [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_criteria_by_index(index: int) -> void:
	criterias[index].remove_fact_reference_log(criterias[index])
	criterias.remove_at(index)
		
		
## ----------------------------------------------------------------------------[br]
## Add a modification to the rule [br]
## [b]Parameter(s):[/b] [br]
## [b]* criteria | ReactionContextModificationItem:[/b] Modification to add to the rule [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_modification(modification: ReactionContextModificationItem) -> void:
	modifications.append(modification)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a modification from the rule using the index [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the modification to remove [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_modification_by_index(index: int) -> void:
	modifications[index].remove_fact_reference_log(modifications[index])
	modifications.remove_at(index)


func get_new_object():
	return ReactionRuleItem.new()
	
	
func _to_string():
	return label
