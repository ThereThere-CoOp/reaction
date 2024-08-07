extends Node

@export var reaction_fact: ReactionComponentVariableFact

@export var reaction_event: ReactionComponentVariableEvent


func _ready():
	print(reaction_fact._selected_object.label)
	print(reaction_event._selected_object.label)
	
