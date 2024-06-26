@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export var responses_types: Dictionary = {"Dialog": "Dialog" }

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	pass


func get_item_type(item: Resource) -> String:
	if item is ReactionEventItem:
		return "Event"
	elif item is ReactionFactItem:
		return "Fact"
	elif item is ReactionRuleItem:
		return "Rule"
	elif item is ReactionRuleCriteria:
		return "Criteria"
	elif item is ReactionContextModification:
		return "Modification"
	elif item is ReactionResponseGroupItem:
		return "Response Group"
	elif item is ReactionResponseItem:
		return "Response"
	elif item is ReactionResponseDialogItem:
		return responses_types["Dialog"]
	else:
		return "Fact"
