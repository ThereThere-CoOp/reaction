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
		rules = ReactionGlobals.sort_rules(value)
		if Engine.is_editor_hint():
			notify_property_list_changed()
			
			
func _init() -> void:
	super()
	_ignore_fields.merge({"fact_reference_log": true})
	label = "NEW_EVENT"
	# reaction_item_type = ReactionGlobals.ItemsTypesEnum.EVENT
	sqlite_table_name = "event"


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
	
	new_event_log_item.old_blackboard = context.clone()
	
	for rule in rules:
		if rule.test(context):
			context.clean_scope("Event")
			
			rule.execute_modifications(context)
			
			new_event_log_item.rule_triggered = rule
			new_event_log_item.new_blackboard = context.clone()
			ReactionSignals.event_execution_log_created.emit(new_event_log_item)
			
			ReactionSignals.rule_executed.emit(rule)
			return rule.response_group.get_responses()

	return []


static func get_new_object():
	var new_event = ReactionEventItem.new()
	return new_event
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.EVENT
