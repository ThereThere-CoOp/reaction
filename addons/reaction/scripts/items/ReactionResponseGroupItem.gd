@tool
class_name ReactionResponseGroupItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a response group.
##
## A response group have at least one response a [ReactionResponseItem] and
## manage the behavior of the responses within it.
## ----------------------------------------------------------------------------


## dict of responses or responses groups
@export var responses = {}


func add_new_response(response_type: String) -> ReactionResponseItem:
	var new_response: ReactionResponseItem
	
	if response_type == ReactionGlobals.responses_types["Dialog"]:
		new_response = ReactionResponseDialogItem.new()
		new_response.label = "newDialogResponse"
	else:
		new_response = ReactionResponseDialogItem.new()
		new_response.label = "newDialogResponse"
	
	responses[new_response.uid] = new_response
	return new_response
		
		
func add_new_response_group() -> ReactionResponseGroupItem:
	var new_response_group = ReactionResponseGroupItem.new()
	new_response_group.label = "newResponseGroup"
	responses[new_response_group.uid] = new_response_group
	return new_response_group
	
	
func remove_response(response_uid: String) -> void:
	responses.erase(response_uid)
	
	
func get_responses():
	return responses.values()
	
	
static func get_new_object() -> ReactionResponseGroupItem:
	var new_response_group = ReactionResponseGroupItem.new()
	new_response_group.label = "newResponseGroup"
	return new_response_group
