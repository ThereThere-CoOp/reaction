@tool
extends Node


const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

@onready var global_context: ReactionBlackboard = ReactionBlackboard.new()


func _ready():
	var databases_path = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)

	var dir = DirAccess.open(databases_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue
			else:
				var resource_path_to_load = "%s/%s" % [databases_path, file_name]
				var database: ReactionDatabase = load(resource_path_to_load) as ReactionDatabase
				databases[database.uid] = database
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access databases path.")
