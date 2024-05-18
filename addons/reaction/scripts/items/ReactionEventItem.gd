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

## array of ordered rules to be checked for this concept,
## rules are ordered for their criteria count in descending order
@export var rules: Array[ReactionRuleItem]:
	set(value):
		var new_rules: Array[ReactionRuleItem] = []
		var temp_priority_rules: Array[ReactionRuleItem] = []
		var temp_non_priority_rules: Array[ReactionRuleItem] = []

		for rule in value:
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

		rules = new_rules

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
	var new_rules: Array[ReactionRuleItem] = rules.duplicate()
	var index = 0
	for rule in new_rules:
		if rule.uid == rule_uid:
			break
		index += 1
	
	new_rules.remove_at(index)
	
	## reordering occurs cause set method
	rules = new_rules
	
	
## ----------------------------------------------------------------------------[br]
## Get responses for this event based on the rules and current world's game
## context [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Current world's game context [br]
## [b]Returns:  Array[[ReactionResponseBaseItem]][/b] [br]
## Responses group of the first matching rule  [br]
## ----------------------------------------------------------------------------
func get_responses(context: ReactionBlackboard) -> Array[ReactionResponseBaseItem]:
	for rule in rules:
		if rule.test(context):
			context.clean_scope("Event")
			rule.execute_modifications(context)
			return rule.responses.get_responses()

	return []


func get_new_object():
	return ReactionEventItem.new()
