@tool
class_name ReactionReferenceLogItem
extends Resource


@export var uid: String

@export var event: ReactionEventItem

@export var rule: ReactionRuleItem

@export var response: ReactionResponseItem

@export var object: Resource


func update_log_objects(new_object: Resource) -> void:
	object = new_object
	var  current_parent = new_object.parent
	
	while current_parent:
		if current_parent is ReactionResponseItem:
			response = current_parent
		if current_parent is ReactionRuleItem:
			rule = current_parent
		if current_parent is ReactionEventItem:
			event = current_parent
			
		current_parent = current_parent.parent
