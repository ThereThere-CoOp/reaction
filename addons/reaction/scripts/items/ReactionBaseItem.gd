@tool
class_name ReactionBaseItem
extends Resource
## ----------------------------------------------------------------------------[br]
## Base parent resource class for reaction items.
##
## A base class for reaction items like facts, rules, concepts and responses.
## Contains common fields and functions for reaction items. [br]
## ----------------------------------------------------------------------------

@export var parents: Array[String] = []

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
	
	
func update_parents(parent_object: Resource) -> void:
	if parent_object and parent_object is ReactionBaseItem:
		var new_parents = parent_object.parents.duplicate()
		new_parents.append(parent_object.uid)
		parents = new_parents
	
	
func add_fact_reference_log(object: ReactionReferenceLogItem) -> void:
	pass
	

func remove_fact_reference_log(item: Resource) -> void:
	pass
