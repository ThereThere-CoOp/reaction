@tool
class_name ReactionCriteriaFunctionFactItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource item to storage and manage a fact.
##
## Class item to storage a possibe fact. A fact represent a state of the 
## game world [br]
## ----------------------------------------------------------------------------


## variant type of the fact
@export var fact: ReactionFactItem


func get_new_object():
	var new_fact = ReactionCriteriaFunctionFactItem.new()
	new_fact.label = "newCriteriaFunctionFact"
	return new_fact
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.FUNC_CRIT_FACT
