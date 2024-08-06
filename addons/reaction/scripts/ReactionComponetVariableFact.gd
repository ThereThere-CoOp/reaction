@tool
class_name ReactionComponentVariableFact
extends ReactionComponentVariable
## ----------------------------------------------------------------------------[br]
## Referenced to a fact 
##
##
## Represents a variable that reference a fact on the blackboard. Allow get the
## variable value and modify it
## [br]
## ----------------------------------------------------------------------------


var fact_value: Variant :
	set(value):
		set_fact_value(value)
		fact_value = value
	get:
		return get_fact_value()
		
		
func _ready():
	super()
	
	_update_objects_array()
	
	if Engine.is_editor_hint():
		notify_property_list_changed()
		
		
func _update_objects_array() -> void:
	_objects_array = database.global_facts.values()
		
		
## ----------------------------------------------------------------------------[br]
## Get the value of the referenced fact. If not context passed use global 
## blackboard [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Context to get fact value
## [br]
## [b]Returns: Variant[/b] [br]
## Value of the fact  [br]
## ----------------------------------------------------------------------------	
func get_fact_value(context: ReactionBlackboard = null) -> Variant:
	if _selected_object:
		if context:
			return context.get_fact_value(_selected_object.uid)
		
		return ReactionGlobals.global_context.get_fact_value(_selected_object.uid)
	
	print("No fact object with uuid %s" % object_uid)
	return null


## ----------------------------------------------------------------------------[br]
## Set the value of the referenced fact. If not context passed use global 
## blackboard [br]
## [b]Parameter(s):[/b] [br]
## [b]* va | [ReactionBlackboard]:[/b] Context to get fact value
## [br]
## [b]* context | [ReactionBlackboard]:[/b] Context to set fact value
## test with the criteria [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------	
func set_fact_value(value: Variant, context: ReactionBlackboard = null) -> void:
	if _selected_object:
		if context:
			context.set_fact_value(_selected_object, value)
		
		ReactionGlobals.global_context.set_fact_value(_selected_object, value)
	else:
		print("No fact object with uuid %s" % object_uid)

