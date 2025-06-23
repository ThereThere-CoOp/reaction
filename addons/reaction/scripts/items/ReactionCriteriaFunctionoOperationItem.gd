@tool
class_name ReactionCriteriaFunctionOperationItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource item to storage and manage a fact.
##
## Class item to storage a possibe fact. A fact represent a state of the 
## game world [br]
## ----------------------------------------------------------------------------


## variant type of the fact
@export var fact: ReactionFactItem

@export_enum("+", "-", "*", "/") var operation: String


func _init() -> void:
	super()

static func get_new_object():
	var new_fact = ReactionCriteriaFunctionOperationItem.new()
	new_fact.label = "newCriteriaFunctionOperation"
	return new_fact
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.FUNC_CRIT_OPERATION
