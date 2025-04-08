@tool
class_name ReactionReferenceLogItem
extends Resource


@export var uid: String

@export var event: ReactionEventItem

@export var rule: ReactionRuleItem

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
			for crit in parent_rule.criterias:
				if crit.uid == splited_parent[1]:
					parent_criteria = crit
			criteria = parent_criteria
				
				
		elif int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP or int(splited_parent[0]) ==  ReactionGlobals.ItemsTypesEnum.RESPONSE or int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.DIALOG:
			parent_response = _get_response(splited_parent[1], parent_rule.responses)
			
			if parent_response:
				response = parent_response
				
				if int(splited_parent[0]) == ReactionGlobals.ItemsTypesEnum.DIALOG:
					for cho in response.choices:
						if cho.uid == object.parents[-1]:
							parent_choice = cho
							
					choice = parent_choice
					
					for text in response.texts:
						if text.uid == object.parents[-1]:
							parent_dialog_text = text
							
					dialog_text = parent_dialog_text
