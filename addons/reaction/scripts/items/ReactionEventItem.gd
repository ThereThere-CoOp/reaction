@tool
class_name ReactionEventItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource item to storage a reaction event.
##
## Event must have label like (OLD_MAN_NPC_CONVERSATION,
## ROOM_DESCRIPTION) that represents the nature of the event. Have attached
## several rules, and the ones that matchs the current world state will return
## the responses attached to it. [br]
## ----------------------------------------------------------------------------

@export var fact_reference_log = {}

## array of ordered rules to be checked for this concept,
## rules are ordered for their criteria count in descending order
@export var rules: Array[ReactionRuleItem]:
	set(value):
		rules = _sort_rules(value)
		if Engine.is_editor_hint():
			notify_property_list_changed()
			

## ----------------------------------------------------------------------------[br]
## fuction to sort rules when have priority higher than 0 [br]
## ----------------------------------------------------------------------------
func _sort_priority_rules(a, b):
	if a.priority < b.priority:
		return true

	if a.priority == b.priority:
		return a.get_criterias_count() > b.get_criterias_count()

	return false
	

## ----------------------------------------------------------------------------[br]
## private fuction to sort rules [br]
## ----------------------------------------------------------------------------
func _sort_rules(rules_array: Array[ReactionRuleItem]) -> Array[ReactionRuleItem]:
	var new_rules: Array[ReactionRuleItem] = []
	var temp_priority_rules: Array[ReactionRuleItem] = []
	var temp_non_priority_rules: Array[ReactionRuleItem] = []

	for rule in rules_array:
		if rule and rule.priority > 0:
			temp_priority_rules.append(rule)
		else:
			temp_non_priority_rules.append(rule)

	temp_priority_rules.sort_custom(_sort_priority_rules)

	temp_non_priority_rules.sort_custom(
		func(a, b): return a.get_criterias_count() > b.get_criterias_count()
	)

	new_rules.append_array(temp_priority_rules)
	new_rules.append_array(temp_non_priority_rules)

	return new_rules
	

## ----------------------------------------------------------------------------[br]
## Add a rule to event and reorder the rules using priority and rule's criteria 
## numbers [br]
## [b]Parameter(s):[/b] [br]
## [b]* rule | ReactionRuleItem:[/b] New rule to add [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func add_rule(rule: ReactionRuleItem) -> void:
	var new_rules: Array[ReactionRuleItem] = rules.duplicate()
	new_rules.append(rule)
	
	## reordering occurs cause set method
	rules = new_rules
	
	
## ----------------------------------------------------------------------------[br]
## Remove a rule from event and reorder the rules using priority and rule's 
## criteria numbers [br]
## [b]Parameter(s):[/b] [br]
## [b]* rule_uid | String:[/b] Uid of the rule to remove [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_rule(rule_uid: String) -> void:
	var index = 0
	for rule in rules:
		if rule.uid == rule_uid:
			rule.remove_fact_reference_log(rule)
			break
			
		index += 1
	
	rules.remove_at(index)
	
	
## ----------------------------------------------------------------------------[br]
## Get responses for this event based on the rules and current world's game
## context [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Current world's game context [br]
## [b]Returns:  Array[[ReactionResponseBaseItem]][/b] [br]
## Responses group of the first matching rule  [br]
## ----------------------------------------------------------------------------
func get_responses(context: ReactionBlackboard) -> Array[ReactionResponseBaseItem]:
	ReactionSignals.event_executed.emit(self)
	
	var new_event_log_item: ReactionEventExecutionLogItem = ReactionEventExecutionLogItem.new()
	new_event_log_item.label = self.label
	new_event_log_item.event_triggered = self
	new_event_log_item.old_blackboard = context.duplicate()
	
	for rule in rules:
		if rule.test(context):
			context.clean_scope("Event")
			
			rule.execute_modifications(context)
			
			new_event_log_item.rule_triggered = rule
			new_event_log_item.new_blackboard = context.duplicate()
			ReactionSignals.event_execution_log_created.emit(new_event_log_item)
			
			ReactionSignals.rule_executed.emit(rule)
			return rule.responses.get_responses()

	return []
	

## ----------------------------------------------------------------------------[br]
## Add an item on the fact references logs
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* object | ReactionReferenceLogItem:[/b] New log item to add [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------	
func add_fact_reference_log(object: ReactionReferenceLogItem) -> void:
	var fact_uid: String = object.object.fact.uid
	if fact_uid in fact_reference_log:
		fact_reference_log[fact_uid][object.uid] = object
	else:
		fact_reference_log[fact_uid] = {}
		fact_reference_log[fact_uid][object.uid] = object
	

## ----------------------------------------------------------------------------[br]
## Remove an item on the fact references logs
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* item | Resource:[/b] Item to removed from the log could be an
## rule, criteria, modification, response or dialog choice [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------	
func remove_fact_reference_log(item: Resource) -> void:
	for object_log in fact_reference_log.values():
		if item is ReactionCriteriaItem or item is ReactionContextModificationItem:
			object_log.erase(item.uid)
		else:
			for log_item in object_log.values():
				if item is ReactionRuleItem:
					if log_item.rule.uid == item.uid:
						object_log.erase(log_item.uid)
						
				if item is ReactionResponseItem:
					if log_item.response.uid == item.uid:
						object_log.erase(log_item.uid)
						
				if item is ReactionDialogChoiceItem:
					if log_item.choice.uid == item.uid:
						object_log.erase(log_item.uid)
						
				## add here extra if for custom items
				

func get_new_object():
	var new_event = ReactionEventItem.new()
	new_event.label = "NEW_EVENT"
	return new_event
