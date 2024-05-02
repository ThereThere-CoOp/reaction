@tool
class_name ReactionDatabase
extends Resource

const ReactionSettings = preload("../utilities/settings.gd")

@export var label: String

@export var uid: String = Uuid.v4()

@export var events: Dictionary = {}

@export var global_facts: Dictionary = {}


func save_data() -> void:
	print("saved_database", self)
	ResourceSaver.save(
		self,
		(
			"%s/%s_%s.tres"
			% [
				ReactionSettings.get_setting(
					ReactionSettings.DATABASES_PATH_SETTING_NAME,
					ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
				),
				label,
				uid
			]
		)
	)


func _to_string():
	return "%s_%s" % [label, uid]
