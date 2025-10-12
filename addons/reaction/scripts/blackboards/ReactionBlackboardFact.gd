class_name ReactionBlackboardFact
extends Resource
## ----------------------------------------------------------------------------[br]
## Resource to storage a fact (a world state) in a blackboard.
##
## A facts is a world state (data) stored in a blackboard or context on a given
## time instant. [br]
## ----------------------------------------------------------------------------

## fact value converted to int for more efficient comparison with rules criteria
@export var value: int

## real readable value of the fact on the blackboard
@export var real_value: Variant:
	set(r_value):
		real_value = r_value
		
		if r_value != null and fact:
			if fact.is_enum:
				# TODO: find better way of handle index search
				var founded_value = fact.enum_names.find(r_value)
				if founded_value != -1:
					value = founded_value
			else:
				value = int(r_value)


## ReactionFactItem reference
@export var fact: ReactionFactItem

	
func get_string() -> String:
	return _to_string()


func _to_string() -> String:
	return "Fact: uid:%s name:%s real value:%s value:%d" % [fact.uid, fact.label, real_value, value]
