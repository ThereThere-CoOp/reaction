@tool
class_name ReactionReferenceLogItem
extends Resource


@export var uid: String

@export var event: ReactionEventItem

@export var rule: ReactionRuleItem

@export var response: ReactionResponseItem

@export var object: Resource


func _get_response(response_uid: String, responses_group: ReactionResponseGroupItem) -> ReactionResponseItem:
	for response in responses_group.responses.values():
		if response is ReactionResponseGroupItem:
			return _get_response(response_uid, response)
		else:
			if response.uid == response_uid:
				return response
		
			
	return null
	
	

func update_log_objects(new_object: Resource, current_database: ReactionDatabase) -> void:
	object = new_object
	uid = object.uid
	# var  current_parents = new_object.parents
	
	if object.parents.size() > 0:
		var parent_event = current_database.events[object.parents[0]]
		event = parent_event
		
		var parent_rule = null
		if object.parents.size() > 1:
			for rul in parent_event.rules:
				if rul.uid == object.parents[1]:
					parent_rule = rul
			rule = parent_rule
		
		if object.parents.size() > 2:
			response = _get_response(object.parents[-2], parent_rule.responses)
