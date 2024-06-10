@tool
class_name ReactionResponseDialogItem
extends ReactionResponseItem
## ----------------------------------------------------------------------------[br]
## A resource item to store a Reaction dialog response.
##
## A dialog response consist of a dialog text and optionally
## could contains options. [br]
## ----------------------------------------------------------------------------

## text line of the dialog
@export_multiline var dialog_text: String

## true if the dialog have choices
@export var has_choice: bool = false

## list of [ReactionDialogChoices] if [b]have_choice=true[/b]
@export var choices: Array[ReactionDialogChoice]


## ----------------------------------------------------------------------------[br]
## Return the array of choices that met their criterias by the current context
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if choice
## match with facts data [br]
## [b]Returns: Array[ReactionDialogChoice][/b] [br]
## Returns array of choices that met their criterias by the current context  [br]
## ----------------------------------------------------------------------------
func get_choices(context: ReactionBlackboard) -> Array[ReactionDialogChoice]:
	var result_choices = []
	if has_choice:
		for choice in choices:
			if choice.test(context):
				result_choices.append(choice)
			
	return result_choices




