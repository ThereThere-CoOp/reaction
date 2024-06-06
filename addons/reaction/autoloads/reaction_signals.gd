@tool
extends Node

# ----------------- database signals ------------------------
# emited when a data in database changed
signal database_data_changed(database: ReactionDatabase)
# emited when a database is selected
signal database_selected(database: ReactionDatabase)

# ----------------- blackboards facts signals ---------------
signal blackboard_fact_modified(fact: ReactionBlackboardFact, real_value: Variant)

# ----------------- ui signals ------------------------------
signal object_list_form_removed(component_id: String, index: int)
