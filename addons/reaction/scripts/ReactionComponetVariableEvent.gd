@tool
class_name ReactionComponentVariableEvent
extends ReactionComponentVariable
## ----------------------------------------------------------------------------[br]
## Reference to a reaction event 
##
##
## Represents a variable that reference a fact on the blackboard. Allow get the
## variable value and modify it
## [br]
## ----------------------------------------------------------------------------
		
		
func _init():
	super()
	
	_update_objects_array()
	
	if Engine.is_editor_hint():
		notify_property_list_changed()
		
		
func _update_objects_array() -> void:
	if database:
		_objects_array = database.events.values()
		
	_update_fields()

