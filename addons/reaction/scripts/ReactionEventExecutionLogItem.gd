@tool
class_name ReactionEventExecutionLogItem
extends RefCounted


var label: String = "LOG_LABEL"

var uid: String = Uuid.v4()

var event_triggered: ReactionEventItem
var rule_triggered: ReactionRuleItem

var trigger_by_event: ReactionEventItem
var trigger_by_rule: ReactionRuleItem

var old_blackboard: ReactionBlackboard
var new_blackboard: ReactionBlackboard
