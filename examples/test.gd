extends Control

@export var database: ReactionDatabase

var context = ReactionBlackboard.new()

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
	test_event.selected_object.get_responses(context)
		
	context.save_data()
