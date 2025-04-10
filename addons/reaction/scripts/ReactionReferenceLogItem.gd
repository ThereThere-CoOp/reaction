@tool
class_name ReactionReferenceLogItem
extends Resource


@export var uid: String

@export var event: ReactionEventItem

@export var rule: ReactionRuleItem

@export var modification: ReactionContextModificationItem

@export var criteria: ReactionCriteriaItem

@export var response: ReactionResponseItem

@export var choice: ReactionDialogChoiceItem

@export var dialog_text: ReactionDialogTextItem

@export var object: Resource


func _get_response(response_uid: String, responses_group: ReactionResponseGroupItem) -> ReactionResponseItem:
	for response in responses_group.responses.values():
		if response is ReactionResponseGroupItem:
			if response_uid == response:
				return response
			else:
				return _get_response(response_uid, response)
		else:
			if response.uid == response_uid:
				return response
		
			
	return null
	
	
func _get_field_by_field_uid(field_name: String, uid: String, parent_object: Resource) -> Resource:
	for item in parent_object.get(field_name):
		if item.uid == uid:
			return item
			
	return null
	
	

func update_log_objects(new_object: Resource, current_database: ReactionDatabase) -> void:
	object = new_object
	uid = object.uid
	# var  current_parents = new_object.parents
	
	var parent_event: ReactionEventItem = null
	var parent_rule: ReactionRuleItem = null
	var parent_response: ReactionResponseItem = null
	var parent_choice: ReactionDialogChoiceItem = null
	var parent_dialog_text: ReactionDialogTextItem = null
		
	for parent: String in object.parents:
		var splited_parent: PackedStringArray = parent.split(":")
		
		# print(splited_parent[0])
		if  int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.EVENT:
			parent_event = current_database.events[splited_parent[1]]
			event = parent_event
				
		elif int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.RULE:
			for rul in parent_event.rules:
				if rul.uid == splited_parent[1]:
					parent_rule = rul
			rule = parent_rule
				
				
		elif int(splited_parent[0]) ==	ReactionGlobals.ItemsTypesEnum.CRITERIA or int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.FUNC_CRITERIA:
			var parent_criteria: ReactionCriteriaItem = null
			
			if parent_dialog_text:
				parent_criteria = _get_field_by_field_uid("criterias", splited_parent[1], parent_dialog_text)
			elif choice:
				parent_criteria = _get_field_by_field_uid("criterias", splited_parent[1], choice)
			else:
				parent_criteria = _get_field_by_field_uid("criterias", splited_parent[1], parent_rule)
				
			criteria = parent_criteria
			
			
		elif int(splited_parent[0]) ==	ReactionGlobals.ItemsTypesEnum.MODIFICATION:
			var parent_modification: ReactionContextModificationItem = null
			
			if parent_dialog_text:
				parent_modification = _get_field_by_field_uid("modifications", splited_parent[1], parent_dialog_text)
			elif choice:
				parent_modification = _get_field_by_field_uid("modifications", splited_parent[1], choice)
			else:
				parent_modification = _get_field_by_field_uid("modifications", splited_parent[1], parent_rule)
				
			modification = parent_modification
				
				
		elif int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP or int(splited_parent[0]) ==  ReactionGlobals.ItemsTypesEnum.RESPONSE or int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.DIALOG:
			parent_response = _get_response(splited_parent[1], parent_rule.responses)
			
			if parent_response:
				response = parent_response
				
		elif int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.CHOICE:
				parent_choice = parent_response.get_choice_by_uid(splited_parent[1])
				choice = parent_choice
				
		elif int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.DIALOG_TEXT:
				parent_dialog_text = parent_response.get_text_by_uid(splited_parent[1])
				dialog_text = parent_dialog_text
				
