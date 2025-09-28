@tool
class_name ReactionUIIText
extends VBoxContainer

const text_item_scene: PackedScene = preload("res://addons/reaction/components/ReactionUIITextItem.tscn")

const ReactionSettings = preload("../utilities/settings.gd")

var current_database: SQLite

var parent_object: Resource

@export var text_field_name: String = "text"

@export var file_paths_field_name: String = "file_path"

@onready var use_file_check_button:  CheckButton = %UseFileCheckButton

@onready var texts_container:  VBoxContainer = %TextsContainer


func setup(parent: Resource) -> void:
	parent_object = parent
	current_database = ReactionGlobals.current_sqlite_database
	
	use_file_check_button = %UseFileCheckButton
	texts_container = %TextsContainer
	
	var settings_language = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	)
	
	var object_texts_dicts = parent_object.get(text_field_name)
	
	use_file_check_button.set_pressed_no_signal(parent.use_file)
	
	for code in settings_language.keys():
		var item_node: ReactionUIITextItem = text_item_scene.instantiate()
		
		item_node.setup(parent_object, text_field_name, file_paths_field_name, code)
		
		texts_container.add_child(item_node)
		
		
### Signals


func _on_text_languaged_changed(text: String, code: String) -> void:
	var texts_dict = parent_object.get(text_field_name).duplicate()
	texts_dict[code] = text
	parent_object.set(text_field_name, texts_dict)
	parent_object.update_sqlite()


func _on_use_file_check_button_toggled(toggled_on: bool) -> void:
	parent_object.use_file = toggled_on
	parent_object.update_sqlite()
		
	for text_item in texts_container.get_children():
		text_item.update()
