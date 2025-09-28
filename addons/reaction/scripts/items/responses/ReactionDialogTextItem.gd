@tool
class_name ReactionDialogTextItem
extends ReactionRuleItem
## ----------------------------------------------------------------------------[br]
## A resource to store Reaction Dialog Text.
##
## A conditional text for a dialog, dependending on the criterias
## and trigger a next event [br]
## ----------------------------------------------------------------------------

## dialog text if option is not used
@export var text: Dictionary = {}

## true if use text file instead
@export var use_file: bool = true

## text files path if use_file = true
@export var file_path: Dictionary = {}


func _init() -> void:
	super()
	label = "newDialogText"
	
	
static func get_new_object():
	return ReactionDialogTextItem.new()
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.DIALOG_TEXT
