extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@export_enum("Dialog Response") var responses_types: String

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	pass
