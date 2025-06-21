@tool
class_name ReactionUIITextItem
extends VBoxContainer

const ReactionSettings = preload("../utilities/settings.gd")

var current_database: SQLite

var object: Resource

var texts_field_name: String

var code: String

@onready var language_label: Label = %LanguageLabel

@onready var text_edit: TextEdit = %TextEdit


func setup(parent: Resource, field_name: String, current_code: String):
	current_database = ReactionGlobals.current_sqlite_database
	object = parent
	texts_field_name = field_name
	code = current_code


func _ready() -> void:
	var settings_language = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	).duplicate()
	
	if code:
		language_label.text = settings_language[code]["name"]
		if code in object.get(texts_field_name):
			text_edit.text = object.get(texts_field_name)[code]


func _on_text_edit_text_changed() -> void:
	var texts_dict: Dictionary = object.get(texts_field_name).duplicate()
	texts_dict[code] = text_edit.text
	object.set(texts_field_name, texts_dict)
	object.update_sqlite()
