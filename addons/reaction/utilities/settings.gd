@tool
extends Node

const REACTION_SETTINGS_BASE_NAME = "reaction"

# settings names
const CURRENT_DATABASE_ID_SETTING_NAME = "current_database_id"
const DATABASES_PATH_SETTING_NAME = "databases_path"
const BLACKBOARDS_SAVE_PATHS_SETTINGS_NAME = "blackboards_save_path"
const DEFAULT_DATABASE_PATH_SETTING_NAME = "default_database_path"
const LANGUAGES_SETTING_NAME = "languages_dict"

# settings default
const DEFAULT_DATABASE_PATH_SETTING_DEFAULT = ""
const DATABASES_PATH_SETTING_DEFAULT = "res://reaction_data"
const BLACKBOARDS_SAVE_PATHS_DEFAULT = "user://reaction_blackboards"
const LANGUAGES_SETTING_DEFAULT = {
	"en": { "name": "English", "code": "en"}, 
	"es": { "name": "Spanish", "code": "es"}
}


static func set_setting(key: String, value) -> void:
	ProjectSettings.set_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key], value)
	ProjectSettings.save()


static func get_setting(key: String, default):
	if ProjectSettings.has_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key]):
		return ProjectSettings.get_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key])

	return default
