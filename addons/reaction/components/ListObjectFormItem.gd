@tool
class_name ListObjectFormItem
extends PanelContainer

signal object_list_form_removed(object_index: int)

@export var object_name: String = "object"

@export var remove_object_function_name: String = "remove_function_name"

var current_database: ReactionDatabase

var current_parent_object: Resource

var object_index: int = -1

var item_object : Resource

var index_text: String

@onready var remove_object_button: Button = %RemoveObjectButton
@onready var index_label: Label = %IndexLabel


func _ready():
	call_deferred("apply_theme")
	
	index_label.text = "#%d" % (object_index + 1)
	remove_object_button.tooltip_text = "Remove %s" % object_name
			
			
func setup(database: ReactionDatabase, parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:	
	current_database = database
	current_parent_object = parent_object
	object_index = index
	item_object = object
	

func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(remove_object_button):
		remove_object_button.icon = get_theme_icon("Remove", "EditorIcons")
		
		
func update_index(new_index: int):
	object_index = new_index
	index_label.text = "#%d" % (new_index + 1)


### Signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_remove_object_button_pressed():
	var remove_function_callable = Callable(current_parent_object, remove_object_function_name)
	remove_function_callable.call(object_index)
	# current_parent_object.remove_modification_by_index(object_index)
	current_database.save_data()
	queue_free()
	object_list_form_removed.emit(object_index)
