@tool
class_name ReactionUIMultiselect
extends MarginContainer


var current_database: ReactionDatabase

var objects_list: Array

var related_object: Resource

@export var object_name: String = "tag"

@export var related_object_relationship_field_name: String = "tags"

@export var list_object_label_field_name: String = "label"

@export var add_related_function_name: String = "add_related"

@export var remove_related_function_name: String = "remove_related"

@onready var selected_button: Button = %SelectedButton
@onready var list_dialog: AcceptDialog = %ListAcceptDialog
@onready var item_list: ItemList = %ItemList


func _ready() -> void:
	list_dialog.title = "Select %s(s)" % object_name
	ReactionSignals.database_selected.connect(_on_database_selected)


func _get_related_objects_list() -> Array:
	var related_objects_field = related_object.get(related_object_relationship_field_name)
	if related_objects_field is Dictionary:
		return related_objects_field.values()
	else:
		return related_objects_field
	
	
func _update_selected_button_text() -> void:
	var current_objects = _get_related_objects_list()
	var result_text = "Select %s(s)" % object_name 
	if current_objects.size() > 0:
		result_text = ""
		for object in current_objects:
			result_text += "%s, " % object.get(list_object_label_field_name)
			
		result_text = result_text.trim_suffix(", ")
		
	selected_button.text = result_text
	selected_button.tooltip_text = result_text
	
	
func _add_object_to_related_field(object: Resource) -> void:
	var add_function_callable = Callable(related_object, add_related_function_name)
	add_function_callable.call(object)
	current_database.save_data()
	_update_selected_button_text()
	
	
func _remove_object_from_related_field(object: Resource) -> void:
	var remove_function_callable = Callable(related_object, remove_related_function_name)
	remove_function_callable.call(object.uid)
	current_database.save_data()
	_update_selected_button_text()
	
	
func _reselect_items() -> void:
	item_list.deselect_all()
	for rel_obj in _get_related_objects_list():
		var index = objects_list.find(rel_obj)
		item_list.select(index, false)


func setup(object: Resource, list: Array) -> void:
	related_object = object
	objects_list = list
	
	item_list.clear()
	for obj in objects_list:
		var current_index = item_list.add_item(obj.get(list_object_label_field_name))
		item_list.set_item_metadata(current_index, obj)
	
	_reselect_items()
	_update_selected_button_text()


### signals


func _on_database_selected(database: ReactionDatabase) -> void:
	current_database = database
	

func _on_selected_button_pressed():
	_reselect_items()
	list_dialog.popup_centered()


func _on_list_accept_dialog_confirmed():
	var selected_indexes = item_list.get_selected_items()
	var result: Array = []
	var typed_result: Array[ReactionTag] = []
	for ind in selected_indexes:
		result.append(item_list.get_item_metadata(ind))
	
	typed_result.assign(result)
	related_object.set(related_object_relationship_field_name, typed_result)
	current_database.save_data()
	_update_selected_button_text()
