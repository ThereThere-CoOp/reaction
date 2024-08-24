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
var real_value: Variant:
	set(r_value):
		if r_value != null:
			if fact.type == TYPE_STRING:
				string_value = r_value
			elif fact.type == TYPE_INT:
				int_value = r_value
			else:
				bool_value = r_value
				
			if fact.is_enum:
				# TODO: find better way of handle index search
				var founded_value = fact.enum_names.find(r_value)
				if founded_value != -1:
					value = founded_value
					real_value = r_value
			else:
				real_value = r_value
				value = int(r_value)

@export var int_value: int

@export var bool_value: bool

@export var string_value: String


## ReactionFactItem reference
@export var fact: ReactionFactItem


func _init():
	if fact:
		if fact.type == TYPE_STRING:
			real_value = string_value
		
		if fact.type == TYPE_INT:
			real_value = int_value
			
		if fact.type == TYPE_BOOL:
			real_value = bool_value
		
	
	
	
func get_string() -> String:
	return _to_string()


func _to_string() -> String:
	return "Fact: uid:%s name:%s real value:%s value:%d" % [fact.uid, fact.label, real_value, value]
