@tool
class_name ReactionComponentVariable
extends Object
## ----------------------------------------------------------------------------[br]
## Referenced to a reaction item on a component 
##
##
## Represents a variable that reference an item. Allow get the
## variable value and modify on components or scenes
## [br]
## ----------------------------------------------------------------------------

const ReactionSettings = preload("../utilities/settings.gd")

@export var database: ReactionDatabase :
	set(value):
		database = value
		object_uid = ""
		object_label = ""
		
		_update_objects_array()
		
		if Engine.is_editor_hint():
			notify_property_list_changed()


## uuid of the object referenced
@export var object_uid: String

## label of the object referenced
@export var object_label: String

## index of the object referenced
@export var object_index: int :
	set(value):
		if value:
			var current_object = _objects_array[value]
			_selected_object = current_object
			object_uid = current_object.uid
			object_label = current_object.label
			
		object_index = value

# object referenced
var _selected_object: Resource

# array of objects to select
var _objects_array: Array[Resource] = []


func _ready():
	_get_database()


func _get_database() -> void:
	if not database:
		if ReactionGlobals.default_database:
			database = ReactionGlobals.default_database
	
		database = ReactionDatabase.new()
		
		
func _update_objects_array() -> void:
	pass
		
		
func _get_property_list() -> Array:
	var properties: Array = []
	
	if database:
		var object_label_hint_string: String = ""

		for object in _objects_array:
			object_label_hint_string += "%s," % object.label 
			
		properties.append_array(
			[
				{
					"name": "object_index",
					"type": TYPE_INT,
					"usage": PROPERTY_USAGE_DEFAULT,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": object_label_hint_string
				}
			]
		)
		
	properties.append_array(
			[
				{
					"name": "object_uid",
					"type": TYPE_STRING,
					"usage": PROPERTY_USAGE_READ_ONLY,
				},
				{
					"name": "object_label",
					"type": TYPE_STRING,
					"usage": PROPERTY_USAGE_READ_ONLY,
				},
			]
		)

	return properties

