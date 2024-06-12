extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	pass
