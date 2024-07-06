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
@export var dialog_text: Dictionary = {}

## true if the dialog have choices
@export var have_choices: bool = false

## list of [ReactionDialogChoices] if [b]have_choice=true[/b]
@export var choices: Array[ReactionDialogChoiceItem]


## ----------------------------------------------------------------------------[br]
## Return the array of choices that met their criterias by the current context
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if choice
## match with facts data [br]
## [b]Returns: Array[ReactionDialogChoice][/b] [br]
## Returns array of choices that met their criterias by the current context  [br]
## ----------------------------------------------------------------------------
func get_choices(context: ReactionBlackboard) -> Array[ReactionDialogChoiceItem]:
	var result_choices = []
	if have_choices:
		for choice in choices:
			if choice.test(context):
				result_choices.append(choice)
			
	return result_choices
	
	
## ----------------------------------------------------------------------------[br]
## Add a new choice to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* None[/b] [br]
## [b]Returns: ReactionDialogChoice[/b] [br]
## The new added dialog choice  [br]
## ----------------------------------------------------------------------------
func add_new_choice() -> ReactionDialogChoiceItem:
	var new_dialog_choice = ReactionDialogChoiceItem.new()
	new_dialog_choice.label = "newDialogChoice"
	choices.append(new_dialog_choice)
			
	return new_dialog_choice
	
	
## ----------------------------------------------------------------------------[br]
## Add a choice to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* choice | ReactionDialogChoice:[/b] Choice to be added
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_choice(choice: ReactionDialogChoiceItem) -> void:
	choices.append(choice)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a choice from the response given an index of the choices array
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the choice to remove
## match with facts data [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_choice_by_index(index: int) -> void:
	choices.remove_at(index)




