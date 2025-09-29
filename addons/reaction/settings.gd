@tool
class_name ReactionSettings extends Node

#region Editor
signal sqlite_databases_path_changed()

const REACTION_SETTINGS_BASE_NAME = "reaction"

# settings names
const CURRENT_DATABASE_ID_SETTING_NAME = "databases/current_database_id"
const SQLITE_DATABASES_PATH_SETTING_NAME = "databases/sqlite_databases_path"
const DEFAULT_RESOURCE_DATABASE_PATH_SETTING_NAME = "databases/default_resource_database_path"
const EXPORT_PATH_SETTING_NAME = "databases/resource_export_path"
const DIALOG_FILES_PATH_SETTING_NAME = "dialogs/dialog_files_path"
const LANGUAGES_SETTING_NAME = "dialogs/languages_dict"
const BLACKBOARDS_SAVE_PATHS_SETTINGS_NAME = "user/blackboards_save_path"


const SETTINGS_CONFIGURATIONS = {
	CURRENT_DATABASE_ID_SETTING_NAME: {
		value = "",
		type = TYPE_STRING,
	},
	SQLITE_DATABASES_PATH_SETTING_NAME: {
		value = "res://reaction_data/databases",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_DIR,
	},
	DEFAULT_RESOURCE_DATABASE_PATH_SETTING_NAME: {
		value = "",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
	},
	EXPORT_PATH_SETTING_NAME: {
		value = "res://reaction_data/export",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_DIR,
	},
	DIALOG_FILES_PATH_SETTING_NAME: {
		value = "res://reaction_data/dialogs",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_DIR,
	},
	LANGUAGES_SETTING_NAME: {
		value = {
			"en": { "name": "English", "code": "en"}, 
			"es": { "name": "Spanish", "code": "es"}
		},
		type = TYPE_DICTIONARY,
	},
	BLACKBOARDS_SAVE_PATHS_SETTINGS_NAME: {
		value = "user://reaction_blackboards",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_DIR,
	},
}


static func prepare() -> void:

	for key: String in SETTINGS_CONFIGURATIONS:
		var setting_config: Dictionary = SETTINGS_CONFIGURATIONS[key]
		var setting_name: String = "%s/%s" % [REACTION_SETTINGS_BASE_NAME, key]
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, setting_config.value)
		ProjectSettings.set_initial_value(setting_name, setting_config.value)
		ProjectSettings.add_property_info({
			"name" = setting_name,
			"type" = setting_config.type,
			"hint" = setting_config.get("hint", PROPERTY_HINT_NONE),
			"hint_string" = setting_config.get("hint_string", "")
		})
		ProjectSettings.set_as_basic(setting_name, not setting_config.has("is_advanced"))
		ProjectSettings.set_as_internal(setting_name, setting_config.has("is_hidden"))

	ProjectSettings.save()


static func set_setting(key: String, value) -> void:
	ProjectSettings.set_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key], value)
	ProjectSettings.save()


static func get_setting(key: String, default):
	if ProjectSettings.has_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key]):
		return ProjectSettings.get_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key])

	return default
	
#endregion
