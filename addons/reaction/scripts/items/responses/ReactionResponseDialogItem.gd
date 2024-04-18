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




