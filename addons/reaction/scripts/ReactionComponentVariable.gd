@tool
class_name ReactionComponentVariable
extends Resource
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
		
		_update_objects_array()
		
		if Engine.is_editor_hint():
			notify_property_list_changed()


## uuid of the object referenced
@export var object_uid: String

var object_index: int:
	set(value):
		var current_object = _objects_array[value]
		selected_object = current_object
		object_uid = current_object.uid
			
		object_index = value

## reaction object referenced
var selected_object: Resource

# array of objects to select
var _objects_array: Array = []


func _init():
	_get_database()
	
	
func _ready():
	pass


func _get_database() -> void:
	if not database:
		database = ReactionDatabase.new()
		var default_database = ReactionGlobals.get_default_database()
		if default_database:
			database = default_database
		
		
func _update_objects_array() -> void:
	pass
		

func _update_fields() -> void:
	if database and _objects_array.size() > 0:
		
		if object_uid:
			for i in _objects_array.size():
				if _objects_array[i].uid == object_uid:
					object_index = i
					break
					
		var current_object = _objects_array[object_index]
		selected_object = current_object
		object_uid = current_object.uid
	else:
		selected_object = null
		object_uid = ""
	
		
func _get_property_list() -> Array:
	var properties: Array = []
	
	if database:
		var object_label_hint_string: String = ""
		
		for object in _objects_array:
			object_label_hint_string += "%s," % object.label 
			
		object_label_hint_string = object_label_hint_string.trim_suffix(",")
			
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

	return properties
		
