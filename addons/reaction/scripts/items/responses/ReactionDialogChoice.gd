@tool
class_name ReactionDialogChoice
extends Resource
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Choice.
##
## A choice for a given dialog, optionally could modify the context
## and trigger a next event [br]
## ----------------------------------------------------------------------------

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
