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
@export var text: Dictionary = {}

## Uuid of the event to trigger when choice is selected
@export var triggers: String

## true if use text file instead
@export var use_file: bool = true

## text files path if use_file = true
@export var file_path: Dictionary = {}


func _init() -> void:
	super()
	label = "newDialogChoice"


func remove_from_sqlite() -> bool:
	var success = super()
	
	var dialog_text_file_paths: Array[String] = []
	
	dialog_text_file_paths.append_array(file_path.values())
		
	ReactionSignals.dialog_text_removed.emit(dialog_text_file_paths)
	return success 
	
	
static func get_new_object():
	return ReactionDialogChoiceItem.new()
	
	
func get_type_string() -> int:
	return ReactionConstants.ITEMS_TYPE_ENUM.CHOICE
