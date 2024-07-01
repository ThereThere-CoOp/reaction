@tool
class_name ReactionDialogChoice
extends Resource
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Choice.
##
## A choice for a given dialog, optionally could modify the context
## and trigger a next event [br]
## ----------------------------------------------------------------------------

var parent: ReactionBaseItem

## label of the dialog choice
@export var label: String

## text of the choice
@export_multiline var choice_text: String


## criterias that the choice have to met
@export var criterias: Array[ReactionRuleCriteria] = []


## modification to apply on the context when the choice is selected
@export var modifications: Array[ReactionContextModification] = []

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
	for modification in modifications:
		modification.execute(context)
		
		
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
func add_criteria(criteria: ReactionRuleCriteria) -> void:
	criterias[index].remove_fact_reference_log(criterias[index])
	criterias.append(criteria)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a criteria from the rule using the index [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the criteria to remove [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_criteria_by_index(index: int) -> void:
	criterias.remove_at(index)
		
		
## ----------------------------------------------------------------------------[br]
## Add a modification to the rule [br]
## [b]Parameter(s):[/b] [br]
## [b]* criteria | ReactionContextModification:[/b] Modification to add to the rule [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_modification(modification: ReactionContextModification) -> void:
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


func add_fact_reference_log(object: ReactionReferenceLogItem) -> void:
	parent.add_fact_reference_log(object)
	

func remove_fact_reference_log(item: Resource) -> void:
	parent.remove_fact_reference_log(item)

	
func get_new_object() -> ReactionDialogChoice:
	var new_dialog_choice = ReactionDialogChoice.new()
	new_dialog_choice.label = "newDialogChoice"
	return new_dialog_choice
