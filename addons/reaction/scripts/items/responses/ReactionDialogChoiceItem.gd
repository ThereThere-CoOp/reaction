@tool
class_name ReactionDialogChoiceItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Choice.
##
## A choice for a given dialog, optionally could modify the context
## and trigger a next event [br]
## ----------------------------------------------------------------------------

## text of the choice
@export var choice_text: Dictionary = {}

## criterias that the choice have to met
@export var criterias: Array[ReactionCriteriaItem] = []

## modification to apply on the context when the choice is selected
@export var modifications: Array[ReactionContextModificationItem] = []

## Uuid of the event to trigger when choice is selected
@export var triggers: String


## ----------------------------------------------------------------------------[br]
## Executes all the modifications of the dialog choice on the context [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Context were the modifictions
## will be applied [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func execute_modifications(context: ReactionBlackboard) -> void:
	var new_event_log: ReactionEventExecutionLogItem = ReactionEventExecutionLogItem.new()
	new_event_log.label = label
	new_event_log.choice_triggered = self
	new_event_log.old_blackboard = context.clone()
	
	for modification in modifications:
		modification.execute(context)
		
		new_event_log.new_blackboard = context.clone()
		ReactionSignals.event_execution_log_created.emit(new_event_log)
		
## ----------------------------------------------------------------------------[br]
## Return true if the choice criterias match with the blackboard context
## passed as parameter, false if not [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if choice
## match with facts data [br]
## [b]Returns: bool[/b] [br]
## Returns true if choice matchs with the context  [br]
## ----------------------------------------------------------------------------
func test(context: ReactionBlackboard) -> bool:
	for criteria in criterias:
		var current_bfact = context.get_blackboard_fact(criteria.fact.uid)

		# if criteria fact do not exists on blackboard
		# choice do not match
		if current_bfact == null:
			return false

		if not criteria.test(current_bfact):
			return false

	return true
	
	
## ----------------------------------------------------------------------------[br]
## Add a criteria to the rule [br]
## [b]Parameter(s):[/b] [br]
## [b]* criteria | ReactionRuleCriteria:[/b] Criteria to add to the rule [br]
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
## [b]* criteria | ReactionContextModification:[/b] Modification to add to the rule [br]
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

	
func get_new_object() -> ReactionDialogChoiceItem:
	var new_dialog_choice = ReactionDialogChoiceItem.new()
	new_dialog_choice.label = "newDialogChoice"
	return new_dialog_choice
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.CHOICE
