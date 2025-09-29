@tool
extends ConfirmationDialog

signal database_updated(database: SQLite)

var data: SQLite = null

@onready var label_edit: LineEdit = %DatabaseNameLineEdit


func _ready() -> void:
	register_text_enter(label_edit)
	confirmed.connect(_on_edit_database_dialog_confirmed)


func edit_database(database: SQLite) -> void:
	label_edit.text = database.get_meta("name", "")
	
	data = database
	popup_centered()
	label_edit.grab_focus()
	label_edit.select_all()


### Signals

func _on_edit_database_dialog_confirmed():
	var database_name = data.get_meta("name", "")
	
	var new_file_name = label_edit.text + ".sqlite"
	if database_name != "":
		var new_path = data.path.get_base_dir()
		new_path = new_path.path_join(new_file_name)
		data.backup_to(new_path)
		ReactionGlobals.remove_sqlite_database(data)
		data.path = new_path
		data.open_db()
	else:
		var databases_path = ReactionSettings.get_setting(
			ReactionSettings.SQLITE_DATABASES_PATH_SETTING_NAME,
			ReactionSettings.SETTINGS_CONFIGURATIONS[ReactionSettings.SQLITE_DATABASES_PATH_SETTING_NAME].value
		)
		var new_database_path = databases_path.path_join(new_file_name)
		
		var empty_database = SQLite.new()
		empty_database.path = "res://addons/reaction/data/empty_database.sqlite"
		empty_database.open_db()
		empty_database.backup_to(new_database_path)
		empty_database.close_db()
		
		data.path = new_database_path
		data.open_db()
		var new_uuid = Uuid.v4()
		data.insert_row("database_uuid", {"uuid": new_uuid})
		data.close_db()
		data.set_meta("uuid", new_uuid)
		
	data.set_meta("name", label_edit.text)
	database_updated.emit(data)
