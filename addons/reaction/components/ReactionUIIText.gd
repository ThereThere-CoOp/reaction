@tool
class_name ReactionUIIText
extends VBoxContainer

const text_item_scene: PackedScene = preload("res://addons/reaction/components/ReactionUIITextItem.tscn")

const ReactionSettings = preload("../utilities/settings.gd")

var current_database: ReactionDatabase

var parent_object: Resource

@export var text_field_name: String


func setup(parent: Resource, database: ReactionDatabase) -> void:
	parent_object = parent
	current_database = database
	
	var settings_language = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	)
	
	var object_texts_dicts = parent_object.get(text_field_name)
	
	for code in settings_language.keys():
		var item_node: ReactionUIITextItem = text_item_scene.instantiate()
		
		item_node.setup(current_database, parent_object, text_field_name, code)
		
		add_child(item_node)
		
		
### Signals


func _on_text_languaged_changed(text: String, code: String) -> void:
	var texts_dict = parent_object.get(text_field_name).duplicate()
	texts_dict[code] = text
	parent_object.set(text_field_name, texts_dict)
	current_database.save_data()

