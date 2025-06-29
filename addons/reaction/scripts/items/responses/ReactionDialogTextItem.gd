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


func _init() -> void:
	super()
	label = "newDialogText"

	
static func get_new_object():
	return ReactionDialogTextItem.new()
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.DIALOG_TEXT
