@tool
class_name ReactionResponseGroupItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a response group.
##
## A response group have at least one response a [ReactionResponseItem] and
## manage the behavior of the responses within it.
## ----------------------------------------------------------------------------


## list of responses or responses groups
@export var responses = {}


func add_new_response(response_type: String) -> ReactionResponseItem:
	return ReactionResponseItem.new()
	
	
func get_responses():
	return responses.values()
	
	
static func get_new_object() -> ReactionResponseGroupItem:
	var new_response_group = ReactionResponseGroupItem.new()
	new_response_group.label = "newResponseGroup"
	return new_response_group
