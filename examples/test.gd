extends Control

var database: ReactionDatabase = preload("res://examples/databases/test_database_7cf1ce19-8baf-4e6e-918f-4856e6cf2150.tres")

var context = ReactionBlackboard.new()

var second_context = ReactionBlackboard.new()

@export var test_event: ReactionComponentVariableEvent

# Called when the node enters the scene tree for the first time.
func _ready():
	context.label = "test_context"
	context.load_data()
	test_event.selected_object.get_responses(context)
	context.save_data()


func _on_timer_timeout() -> void:
	var context_union: ReactionBlackboard = ReactionBlackboard.new()
	context_union.merge([context, second_context], false, false)
	test_event.selected_object.get_responses(context_union)
	context.save_data()
