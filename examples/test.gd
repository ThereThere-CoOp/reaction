extends Control

var database: ReactionDatabase = preload("res://examples/databases/test_database_7cf1ce19-8baf-4e6e-918f-4856e6cf2150.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_context = ReactionBlackboard.new()
	database.events["e37048d4-978a-4893-a02a-d3fb984f49da"].get_responses(new_context)
