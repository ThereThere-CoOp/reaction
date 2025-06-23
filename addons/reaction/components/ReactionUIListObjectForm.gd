@tool
class_name ReactionUIListObjectForm
extends MarginContainer

signal object_added(object: Resource)

signal object_removed()

var current_parent_object: Resource

@export var objects_to_add_data_array: Array[ListObjectFormObjectToAdd] = []
 
# @export var object_name: String = "object"
@export var list_resource_class: Resource

# @export var parent_object_add_function_name: String = "addObjects"
# @export var object_resource_class: Resource
@export var object_scene = preload("res://addons/reaction/components/ReactionUICriteria.tscn")

# @onready var add_object_button : Button = %AddObjectButton
@onready var add_objects_menu_button: MenuButton = %AddObjectsMenuButton
@onready var objects_rows : VBoxContainer
@onready var objects_scroll_container : ScrollContainer = %ObjectsScrollContainer
@onready var _objects_scrollbar: VScrollBar = objects_scroll_container.get_v_scroll_bar()

var _objects_scroll_to_end = false

var _sqlite_database: SQLite

func _ready():
	# add_object_button.text = "Add %s" % object_name
	var add_object_menu_button_popup: Popup = add_objects_menu_button.get_popup()
	
	for object_data: ListObjectFormObjectToAdd in objects_to_add_data_array:
		add_object_menu_button_popup.add_item("Add %s" % object_data.object_name)
	
	
	ReactionSignals.database_selected.connect(_on_database_selected)
	_objects_scrollbar.changed.connect(_on_objects_scroll_changed)
	add_object_menu_button_popup.index_pressed.connect(_on_add_object_popup_index_pressed)
	# add_object_button.pressed.connect(_on_add_object_button_pressed)
	
	
func _get_resource_from_type(type: int) -> ReactionBaseItem:
	for resource in objects_to_add_data_array:
		if type == resource.object_resource_class.reaction_item_type:
			return resource.object_resource_class
			
	return null
	

func _get_current_object_list():
	var tmp_resource_list = list_resource_class.get_new_object()
	tmp_resource_list.parent_item = current_parent_object
	var objects_list = tmp_resource_list.get_sqlite_list()
	return objects_list


func setup_objects(parent_object: Resource) -> void:
	objects_rows = %ObjectsRows
	
	if parent_object:
		current_parent_object = parent_object
		
		for object in objects_rows.get_children():
			object.queue_free()
		
		_objects_scroll_to_end = false
		var index = 0
		
		var objects_list = _get_current_object_list()
		 
		for object_data in objects_list:
			var current_resource = _get_resource_from_type(object_data.get("reaction_item_type"))
			var reaction_item = current_resource.get_new_object()
			reaction_item.deserialize(object_data)
			var new_object = object_scene.instantiate()
			new_object.setup(current_parent_object, reaction_item, index)
			new_object.object_list_form_removed.connect(_on_object_removed)
			objects_rows.add_child(new_object)
			index += 1


### signals


func _on_database_selected() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database


func _on_add_object_popup_index_pressed(index: int):
	
	var object_data: ListObjectFormObjectToAdd = objects_to_add_data_array[index]
	var new_object = object_data.object_resource_class.get_new_object()
	new_object.parent_item = current_parent_object

	new_object.add_to_sqlite()
	var objects_list = _get_current_object_list()
	var list_index = objects_list.size() - 1
	var item_ui = object_scene.instantiate()
	item_ui.setup(current_parent_object, new_object, list_index, true)
	_objects_scroll_to_end = true
	item_ui.object_list_form_removed.connect(_on_object_removed)
	objects_rows.add_child(item_ui)
	object_added.emit(new_object)
	
	
func _on_objects_scroll_changed() -> void:
	if _objects_scroll_to_end:
		objects_scroll_container.set_v_scroll(int(_objects_scrollbar.max_value))
		
		
func _on_object_removed(index: int) -> void:
	var current_objects_array = _get_current_object_list()
	
	var current_object_form_components = objects_rows.get_children()
	if index < current_objects_array.size():
		for i in range(index, current_object_form_components.size()):
			current_object_form_components[i].update_index(i - 1)
			
	object_removed.emit()
			
			
	
