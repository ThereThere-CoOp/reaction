@tool
class_name ReactionEventExecutionLogItem
extends RefCounted
## ----------------------------------------------------------------------------[br]
## Resource use to store events execution log
##
## Store the event called, the rule that matches, the blackboard before and
## after the modifications were called and if choice executed
## [br]
## ----------------------------------------------------------------------------


var label: String = "LOG_LABEL"

var uid: String = Uuid.v4()

## choice triggered if the case
var choice_triggered: ReactionDialogChoiceItem

## stored event triggered
var event_triggered: ReactionEventItem
## stored rule triggered
var rule_triggered: ReactionRuleItem

var trigger_by_event: ReactionEventItem
var trigger_by_rule: ReactionRuleItem

## blackboard status before modifications applied
var old_blackboard: ReactionBlackboard
## blackboard status before modifications applied
var new_blackboard: ReactionBlackboard
