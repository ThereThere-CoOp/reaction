@tool
class_name ReactionBaseItem
extends Resource
## ----------------------------------------------------------------------------[br]
## Base parent resource class for reaction items.
##
## A base class for reaction items like facts, rules, concepts and responses.
## Contains common fields and functions for reaction items. [br]
## ----------------------------------------------------------------------------

@export_group("Reaction item general data")
@export var uid: String = Uuid.v4()

@export var label: String = "item_label"
@export_multiline var description: String = "Item long description"

@export_enum("Global", "Event") var scope: String = "Global"

@export var tags: Array[ReactionTag]

@export_group("")


func add_tag(tag: ReactionTag) -> void:
	tags.append(tag)
	
	
func remove_tag(tag_uid: String) -> void:
	var index = 0
	for tag in tags:
		if tag.uid == tag_uid:
			break
		
		index += 1
		
	tags.remove_at(index)
