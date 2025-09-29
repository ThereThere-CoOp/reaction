@tool
class_name ReactionTagItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource use to label or group reaction item
##
## A tag represent a category of a group of reaction items.
## [br]
## ----------------------------------------------------------------------------

## each key is the uid of the facts with this tag
@export var facts: Dictionary = {}


func _init() -> void:
	super()
	label = "newTag"
	_ignore_fields.merge(
		{ "facts": true }
	)
	sqlite_table_name = "tag"
	# reaction_item_type = ReactionGlobals.ItemsTypesEnum.TAG


static func get_new_object() -> ReactionTagItem:
	var new_tag = ReactionTagItem.new()
	return new_tag
	
	
func get_type_string() -> int:
	return ReactionConstants.ITEMS_TYPE_ENUM.TAG
	
	
