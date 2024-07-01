@tool
class_name ListObjectForm
extends MarginContainer

signal object_added(object: Resource)

signal object_removed()

var current_database: ReactionDatabase
var current_parent_object: Resource

@export var object_name: String = "object"
@export var objects_list_field_name: String = "objects"
@export var parent_object_add_function_name: String = "addObjects"
@export var object_resource_class: Resource
@export var object_scene = preload("res://addons/reaction/components/Criteria.tscn")

@onready var add_object_button : Button = %AddObjectButton
@onready var objects_rows : VBoxContainer = %ObjectsRows
@onready var objects_scroll_container : ScrollContainer = %ObjectsScrollContainer
@onready var _objects_scrollbar: VScrollBar = objects_scroll_container.get_v_scroll_bar()

var _objects_scroll_to_end = false

func _ready():
	add_object_button.text = "Add %s" % object_name
	
	ReactionSignals.database_selected.connect(_on_database_selected)
	_objects_scrollbar.changed.connect(_on_objects_scroll_changed)
	add_object_button.pressed.connect(_on_add_object_button_pressed)


func setup_objects(parent_object: Resource) -> void:
	current_parent_object = parent_object
	
	for object in objects_rows.get_children():
		object.queue_free()
	
	_objects_scroll_to_end = false
	var index = 0
	for object in current_parent_object.get(objects_list_field_name):
		var new_object = object_scene.instantiate()
		new_object.setup(current_database, current_parent_object, object, index)
		new_object.object_list_form_removed.connect(_on_object_removed)
		objects_rows.add_child(new_object)
		index += 1


### signals


func _on_database_selected(database: ReactionDatabase) -> void:
	current_database = database


func _on_add_object_button_pressed():
	var new_object = object_resource_class.get_new_object()
	new_object.parent = current_parent_object
	new_object.label = "new_%s" % object_name
	var add_function_callable = Callable(current_parent_object, parent_object_add_function_name)
	add_function_callable.call(new_object)
	current_database.save_data()
	var index = current_parent_object.get(objects_list_field_name).size() - 1
	var item_ui = object_scene.instantiate()
	item_ui.setup(current_database, current_parent_object, new_object, index, true)
	_objects_scroll_to_end = true
	item_ui.object_list_form_removed.connect(_on_object_removed)
	objects_rows.add_child(item_ui)
	object_added.emit(new_object)
	
	
func _on_objects_scroll_changed() -> void:
	if _objects_scroll_to_end:
		objects_scroll_container.set_v_scroll(int(_objects_scrollbar.max_value))
		
		
func _on_object_removed(index: int) -> void:
	var current_objects_array = current_parent_object.get(objects_list_field_name)
	var current_object_form_components = objects_rows.get_children()
	if index < current_objects_array.size():
		for i in range(index, current_object_form_components.size()):
			current_object_form_components[i].update_index(i - 1)
			
	object_removed.emit()
			
			
	
