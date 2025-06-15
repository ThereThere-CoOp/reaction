@tool
class_name ReactionTag
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource use to label or group reaction item
##
## A tag represent a category of a group of reaction items.
## [br]
## ----------------------------------------------------------------------------

@export var facts: Dictionary = {}


func _init() -> void:
	super()
	label = "newTag"


func get_new_object() -> ReactionTag:
	var new_tag = ReactionTag.new()
	return new_tag
	
	
