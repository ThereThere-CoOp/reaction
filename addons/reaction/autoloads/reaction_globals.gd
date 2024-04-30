@tool
extends Node

var databases: Dictionary = {}

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()
