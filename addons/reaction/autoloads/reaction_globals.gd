@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	pass
	
	
func get_response_type(response: ReactionResponseBaseItem) -> String:
	if response is ReactionResponseGroupItem:
		return "Response Group"
	elif response is ReactionResponseDialogItem:
		return responses_types["Dialog"]
	else:
		return "Response Group"
