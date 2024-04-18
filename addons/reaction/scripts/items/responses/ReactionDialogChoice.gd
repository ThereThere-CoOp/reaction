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

## modification to apply on the context when the choice is selected
@export var modifications: Array[ReactionContextModification] = []

## event to trigger when choice is selected
@export var triggers: ReactionEventItem


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