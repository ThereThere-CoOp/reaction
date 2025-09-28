@tool
extends Node

# ----------------- database signals ------------------------
# emited when a data in database changed
signal database_data_changed(database: ReactionDatabase)
# emited when a database is selected
signal database_selected()

# ------------------ plugin signals ------------------------
signal opened_dialog_file(path: String)

signal created_dialog_file(path: String)

# ----------------- blackboards facts signals ---------------
signal blackboard_fact_modified(fact: ReactionBlackboardFact, real_value: Variant)

# ----------------- execution/debug signals ------------------
signal event_executed(event: ReactionEventItem)

signal rule_executed(rule: ReactionRuleItem)

signal response_executed(response: ReactionResponseItem)

signal event_execution_log_created(new_event_log: ReactionEventExecutionLogItem)
