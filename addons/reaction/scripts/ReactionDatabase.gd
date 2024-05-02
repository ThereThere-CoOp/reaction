@tool
class_name ReactionDatabase
extends Resource

const ReactionSettings = preload("../utilities/settings.gd")

@export var label: String

@export var uid: String = Uuid.v4()

@export var events: Dictionary = {}

@export var global_facts: Dictionary = {}


func save_data() -> void:
	ResourceSaver.save(
		self,
		(
			"%s/%s_%s.tres"
			% [
				ReactionSettings.get_setting(
					ReactionSettings.DATABASES_PATH_SETTING_NAME,
					ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
				),
				label.replace(" ", "_"),
				uid
			]
		)
	)


func remove_savedata() -> void:
	var databases_path = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)

	var file_path = (
		"%s/%s_%s.tres" % [databases_path, label.replace(" ", "_"), uid]
	)

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)

func _to_string():
	return "%s_%s" % [label, uid]
