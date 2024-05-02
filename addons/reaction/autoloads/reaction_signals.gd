@tool
extends Node

# database signals
signal database_data_changed(database: ReactionDatabase)

# blackboards facts signals
signal blackboard_fact_modified(fact: ReactionBlackboardFact, real_value: Variant)
