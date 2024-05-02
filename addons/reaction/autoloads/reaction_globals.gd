extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	pass
