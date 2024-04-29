extends Node

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()

var databases: Dictionary = {}

var current_database_uid: String
