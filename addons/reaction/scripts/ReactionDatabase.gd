class_name ReactionDatabase
extends Resource

@export var label: String

@export var uid: String = Uuid.v4()

@export var events: Dictionary = {}

@export var global_facts: Dictionary = {}
