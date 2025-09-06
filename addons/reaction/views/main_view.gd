@tool
extends Control

const ReactionSettings = preload("../utilities/settings.gd")

const ExportDatabase = preload("../utilities/export_database.gd")

var databases: Dictionary = {}

var current_database_id: String = ""

var current_sqlite_database: SQLite


var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

@onready var add_database_button = %AddDatabaseButton
@onready var database_menu_button = %DatabaseMenuButton
@onready var edit_database_button = %EditDatabaseButton
@onready var remove_database_button = %RemoveDatabaseButton
@onready var export_database_as_resource_button = %ExportDatabaseAsResourceButton
@onready var settings_button = %SettingsButton
@onready var resource_database_name_lineedit: LineEdit = %ResourceDatabaseNameLineEdit

# panels
@onready var database_managment_panel = %DatabaseDataManagment
@onready var global_facts_panel = %GlobalFacts
@onready var events_panel = %Events
@onready var rules_panel = %Rules
@onready var tags_panel = %Tags
@onready var responses_panel = %"All Responses"

# dialogs
@onready var edit_database_dialog = %EditDatabaseDialog
@onready var remove_database_dialog = %RemoveDatabaseConfirmationDialog
@onready var export_database_resource_confirmation_dialog = %ExportDatabaseResourceConfirmationDialog
@onready var settings_dialog = %SettingsDialog


func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("apply_theme")

		load_databases_update_view()
		edit_database_dialog.database_updated.connect(_on_edit_database_dialog_database_updated)


func load_databases_from_filesystem() -> void:
	databases.clear()
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
				var path_to_load = databases_path.path_join(file_name)
				var database: SQLite = SQLite.new()
				database.set_meta("name", file_name.get_basename())
				database.path = path_to_load
				
				database.open_db()
				database.foreign_keys = true
				var result = database.select_rows("database_uuid", "", ["*"])
				if len(result) > 0:
					result = result[0]
				database.close_db()
				databases[result["uuid"]] = database
				database.set_meta("uuid", result["uuid"])
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access databases path.")


func load_databases_update_view() -> void:
	load_databases_from_filesystem()
	go_to_database(
		ReactionSettings.get_setting(ReactionSettings.CURRENT_DATABASE_ID_SETTING_NAME, "")
	)
	if current_database_id != "" and databases.has(current_database_id):
		pass
	else:
		current_database_id = ""


func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(add_database_button):
		add_database_button.icon = get_theme_icon("New", "EditorIcons")
		database_menu_button.icon = get_theme_icon("Script", "EditorIcons")
		edit_database_button.icon = get_theme_icon("Edit", "EditorIcons")
		remove_database_button.icon = get_theme_icon("Remove", "EditorIcons")
		export_database_as_resource_button.icon = get_theme_icon("Save", "EditorIcons")
		settings_button.icon = get_theme_icon("Tools", "EditorIcons")


func go_to_database(id: String) -> void:
	if current_database_id != id:
		# save_board()
		if current_database_id != "":
			current_sqlite_database.close_db()
		
		current_database_id = id
		ReactionSettings.set_setting(ReactionSettings.CURRENT_DATABASE_ID_SETTING_NAME, id)
		
		if databases.has(current_database_id):
			ReactionGlobals.current_sqlite_database = databases.get(current_database_id)
			current_sqlite_database = ReactionGlobals.current_sqlite_database
			current_sqlite_database.open_db()
			current_sqlite_database.foreign_keys = true
			# board.from_serialized(board_data)

	if current_database_id == "" or not databases.has(current_database_id):
		database_managment_panel.hide()
		edit_database_button.disabled = true
		remove_database_button.disabled = true
	else:
		database_managment_panel.show()
		edit_database_button.disabled = false
		remove_database_button.disabled = false
		
		# emit database selected signal to setup database panel data
		ReactionSignals.database_selected.emit()
		# global_facts_panel.setup_facts(databases[current_database_id])
		# events_panel.setup_events(databases[current_database_id])

	build_databases_menu()


func _on_main_view_theme_changed() -> void:
	apply_theme()


func build_databases_menu() -> void:
	var menu: PopupMenu = database_menu_button.get_popup()
	menu.clear()

	if menu.index_pressed.is_connected(_on_databases_menu_index_pressed):
		menu.index_pressed.disconnect(_on_databases_menu_index_pressed)

	if databases.size() == 0:
		database_menu_button.text = "No databases yet"
		database_menu_button.disabled = true
	else:
		database_menu_button.disabled = false

		# Add databases labels to the menu in alphabetical order
		var labels := []
		for database: SQLite in databases.values():
			labels.append(database.get_meta("name", ""))
		labels.sort()
		for label in labels:
			menu.add_icon_item(get_theme_icon("Script", "EditorIcons"), label)

		if databases.has(current_database_id):
			database_menu_button.text = (databases.get(current_database_id).get_meta("name", ""))
		menu.index_pressed.connect(_on_databases_menu_index_pressed)


func set_database_data(data: SQLite) -> void:
	databases[data.get_meta("uuid", "")] = data
	build_databases_menu()


func _remove_database(uid: String) -> void:
	ReactionGlobals.remove_sqlite_database(databases[uid])
	databases.erase(uid)
	go_to_database(databases.keys().front() if databases.size() > 0 else "")
	build_databases_menu()


func _remove_database_savefile(data: SQLite) -> void:
	ReactionGlobals.remove_sqlite_database(data)


func remove_database() -> void:
	var database_data = databases.get(current_database_id)
	# var undo_database_data = DeepClone.deep_clone(database_data)

	undo_redo.create_action("Delete database")
	undo_redo.add_do_method(self, "_remove_database", current_database_id)
	undo_redo.add_undo_method(self, "_unremove_database", database_data)
	undo_redo.commit_action()


func _unremove_database(data: SQLite) -> void:
	var uuid = data.get_meta("uuid", "")
	databases[uuid] = data
	build_databases_menu()
	go_to_database(uuid)


### signals


func _on_add_database_button_pressed() -> void:
	edit_database_dialog.edit_database(SQLite.new())


func _on_edit_database_button_pressed() -> void:
	edit_database_dialog.edit_database(databases[current_database_id])


func _on_remove_database_button_pressed():
	remove_database_dialog.dialog_text = ("Remove '%s'?" % databases.get(current_database_id).get_meta("name", ""))
	remove_database_dialog.popup_centered()


func _on_remove_database_confirmation_dialog_confirmed():
	remove_database()


func _on_settings_button_pressed():
	settings_dialog.get_child(0).setup_settings()
	settings_dialog.popup_centered()


func _on_edit_database_dialog_database_updated(data: SQLite):
	var data_uuid = data.get_meta("uuid", "")
	if databases.has(data_uuid):
		var current_data = databases.get(data_uuid)
		undo_redo.create_action("Set database data")
		undo_redo.add_do_method(self, "_remove_database_savefile", current_data)
		undo_redo.add_do_method(self, "set_database_data", data)
		undo_redo.add_undo_method(self, "set_database_data", current_data)
		undo_redo.add_undo_method(self, "_remove_database_savefile", data)
		undo_redo.commit_action()
	else:
		undo_redo.create_action("Set database data")
		undo_redo.add_do_method(self, "set_database_data", data)
		undo_redo.add_undo_method(self, "_remove_database", data_uuid)
		undo_redo.add_do_method(self, "go_to_database", data_uuid)
		undo_redo.add_undo_method(self, "go_to_database", current_database_id)
		undo_redo.commit_action()


func _on_database_menu_about_to_popup() -> void:
	build_databases_menu()


func _on_databases_menu_index_pressed(index):
	var popup = database_menu_button.get_popup()
	var label = popup.get_item_text(index)
	for database: SQLite in databases.values():
		if database.get_meta("name", "") == label:
			undo_redo.create_action("Change database")
			undo_redo.add_do_method(self, "go_to_database", database.get_meta("uuid", ""))
			undo_redo.add_undo_method(self, "go_to_database", current_database_id)
			undo_redo.commit_action()


func _on_setting_database_path_updated() -> void:
	load_databases_update_view()


func _on_database_data_managment_tab_selected(tab):
	if tab:
		match tab:
			0:
				global_facts_panel.setup_facts()
			1:
				events_panel.setup_events()
			2:
				responses_panel.setup_responses()
			3:
				tags_panel.setup_tags()
			_:
				global_facts_panel.setup_facts()


func _on_export_database_as_resource_button_pressed() -> void:
	export_database_resource_confirmation_dialog.title = ("Export database '%s'?" % databases.get(current_database_id).get_meta("name", ""))
	export_database_resource_confirmation_dialog.popup_centered()


func _on_export_database_resource_confirmation_dialog_confirmed() -> void:
	var database_name = "new_database_export"
	
	if resource_database_name_lineedit.text != "":
		database_name = resource_database_name_lineedit.text
		
	var new_database: ReactionDatabase = ExportDatabase.get_resource_from_sqlite_database()
	new_database.label = database_name
	new_database.save_data()
		
	
		
