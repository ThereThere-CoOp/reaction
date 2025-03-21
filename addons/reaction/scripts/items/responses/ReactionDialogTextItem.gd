@tool
class_name ReactionDialogTextItem
extends ReactionRuleItem
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Text.
##
## A conditional text for a dialog, dependending on the criterias
## and trigger a next event [br]
## ----------------------------------------------------------------------------

## text of the choice
@export var text: Dictionary = {}

	
func get_new_object() -> ReactionDialogTextItem:
	var new_dialog_text = ReactionDialogTextItem.new()
	new_dialog_text.label = "newDialogText"
	return new_dialog_text
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.DIALOG_TEXT
