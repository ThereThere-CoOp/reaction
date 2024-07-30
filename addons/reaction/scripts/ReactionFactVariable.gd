@tool
class_name ReactionFactVariable
extends Object
## ----------------------------------------------------------------------------[br]
## Referenced to a fact 
##
##
## Represents a variable that reference a fact on the blackboard. Allow get the
## variable value and modify it
## [br]
## ----------------------------------------------------------------------------

const ReactionSettings = preload("../utilities/settings.gd")

@export var database: ReactionDatabase

## uuid of the fact referenced
@export var fact_uuid: String :
	set(value):
		if value in database.global_facts:
			_fact_object = database.global_facts[value]
			fact_label = _fact_object.label
			
		fact_uuid = value
		if Engine.is_editor_hint():
			notify_property_list_changed()

## label of the fact referenced
@export var fact_label: String

# fact object referenced
var _fact_object: ReactionFactItem


func _ready():
	_get_database()
	

func _get_database() -> void:
	if not database:
		if ReactionGlobals.default_database:
			database = ReactionGlobals.default_database
	
		database = ReactionDatabase.new()
		

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
	if _fact_object:
		if context:
			return context.get_fact_value(_fact_object.uid)
		
		return ReactionGlobals.global_context.get_fact_value(_fact_object.uid)
	
	print("No fact object with uuid %s" % fact_uuid)
	return null
	

## ----------------------------------------------------------------------------[br]
## Set the value of the referenced fact. If not context passed use global 
## blackboard [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Context to set fact value
## test with the criteria [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------	
func set_fact_value(value: Variant, context: ReactionBlackboard = null) -> void:
	if _fact_object:
		if context:
			context.set_fact_value(_fact_object, value)
		
		ReactionGlobals.global_context.set_fact_value(_fact_object, value)
	else:
		print("No fact object with uuid %s" % fact_uuid)

