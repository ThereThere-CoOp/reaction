extends Control

var database: ReactionDatabase = preload("res://examples/databases/test_database_3043f628-c225-4be1-a72f-972825de7386.tres")

var context = ReactionBlackboard.new()

var second_context = ReactionBlackboard.new()

@onready var reaction_test_component = %ReactionComponentTest

@export var test_event: ReactionComponentVariableEvent

# Called when the node enters the scene tree for the first time.
func _ready():
	context.label = "test_context"
	context.load_data()
	test_event.selected_object.get_responses(context)
	
	# print(reaction_test_component.reaction_fact.get_fact_value(context))
	
	context.save_data()


func _on_timer_timeout() -> void:
	var context_union: ReactionBlackboard = ReactionBlackboard.new()
	context_union.merge([context, second_context], false, false)
	test_event.selected_object.get_responses(context_union)
	
	# print(reaction_test_component.reaction_fact.get_fact_value(context))
	
	context.save_data()
