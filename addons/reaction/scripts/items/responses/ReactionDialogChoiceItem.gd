@tool
class_name ReactionDialogChoiceItem
extends ReactionRuleItem
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Choice.
##
## A choice for a given dialog, optionally could modify the context
## and trigger a next event [br]
## ----------------------------------------------------------------------------

## text of the choice
@export var choice_text: Dictionary = {}

## Uuid of the event to trigger when choice is selected
@export var triggers: String

	
static func get_new_object():
	var new_dialog_choice = ReactionDialogChoiceItem.new()
	new_dialog_choice.label = "newDialogChoice"
	return new_dialog_choice
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.CHOICE
