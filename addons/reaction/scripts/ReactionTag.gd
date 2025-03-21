@tool
class_name ReactionTag
extends Resource
## ----------------------------------------------------------------------------[br]
## Resource use to label or group reaction item
##
## A tag represent a category of a group of reaction items.
## [br]
## ----------------------------------------------------------------------------


## label of the tag
@export var label: String = "tagLabel"

## Uid of the tag
@export var uid: String = Uuid.v4()

## description of the tag
@export_multiline var description: String

@export var facts: Dictionary = {}

func get_new_object() -> ReactionTag:
	var new_tag = ReactionTag.new()
	new_tag.label = "newTag"
	return new_tag
	
	
func update_parents(parent_object: Resource) -> void:
	pass
