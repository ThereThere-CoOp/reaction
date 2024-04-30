@tool
extends Node

const REACTION_SETTINGS_BASE_NAME = "reaction"


static func set_setting(key: String, value) -> void:
	ProjectSettings.set_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key], value)
	ProjectSettings.save()


static func get_setting(key: String, default):
	if ProjectSettings.has_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key]):
		return ProjectSettings.get_setting("%s/%s" % [REACTION_SETTINGS_BASE_NAME, key])

	return default
