@tool
extends Control

const ReactionSettings = preload("../utilities/settings.gd")

var databases: Dictionary = {}

var current_database_id: String = ""

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

@onready var add_database_button = %AddDatabaseButton
@onready var database_menu_button = %DatabaseMenuButton
@onready var edit_database_button = %EditDatabaseButton
@onready var remove_database_button = %RemoveDatabaseButton
@onready var settings_button = %SettingsButton
# panels
@onready var database_managment_panel = %DatabaseDataManagment
@onready var global_facts_panel = %GlobalFacts
@onready var events_panel = %Events
# dialogs
@onready var edit_database_dialog = %EditDatabaseDialog
@onready var remove_database_dialog = %RemoveDatabaseConfirmationDialog
@onready var settings_dialog = %SettingsDialog


func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("apply_theme")

		load_databases_update_view()


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
				var resource_path_to_load = "%s/%s" % [databases_path, file_name]
				var database: ReactionDatabase = load(resource_path_to_load) as ReactionDatabase
				databases[database.uid] = database
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
		settings_button.icon = get_theme_icon("Tools", "EditorIcons")


func go_to_database(id: String) -> void:
	if current_database_id != id:
		# save_board()

		current_database_id = id
		ReactionSettings.set_setting(ReactionSettings.CURRENT_DATABASE_ID_SETTING_NAME, id)

		if databases.has(current_database_id):
			var database_data = databases.get(current_database_id)
			# board.from_serialized(board_data)

	if current_database_id == "" or not databases.has(current_database_id):
		database_managment_panel.hide()
		edit_database_button.disabled = true
		remove_database_button.disabled = true
	else:
		database_managment_panel.show()
		edit_database_button.disabled = false
		remove_database_button.disabled = false
		global_facts_panel.setup_facts(databases[current_database_id])

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
		for database in databases.values():
			labels.append(database.label)
		labels.sort()
		for label in labels:
			menu.add_icon_item(get_theme_icon("Script", "EditorIcons"), label)

		if databases.has(current_database_id):
			database_menu_button.text = (databases.get(current_database_id).label)
		menu.index_pressed.connect(_on_databases_menu_index_pressed)


func set_database_data(data: ReactionDatabase) -> void:
	databases[data.uid] = data
	data.save_data()
	build_databases_menu()


func _remove_database(uid: String) -> void:
	databases[uid].remove_savedata()
	databases.erase(uid)
	go_to_database(databases.keys().front() if databases.size() > 0 else "")
	build_databases_menu()


func _remove_database_savefile(data: ReactionDatabase) -> void:
	data.remove_savedata()


func remove_database() -> void:
	var database_data = databases.get(current_database_id)
	var undo_database_data = DeepClone.deep_clone(database_data)

	undo_redo.create_action("Delete database")
	undo_redo.add_do_method(self, "_remove_database", current_database_id)
	undo_redo.add_undo_method(self, "_unremove_board", undo_database_data)
	undo_redo.commit_action()


func _unremove_board(data: ReactionDatabase) -> void:
	databases[data.uid] = data
	build_databases_menu()
	go_to_database(data.uid)
	data.save_data()


### signals


func _on_add_database_button_pressed() -> void:
	edit_database_dialog.edit_database(ReactionDatabase.new())


func _on_edit_database_button_pressed() -> void:
	edit_database_dialog.edit_database(databases[current_database_id])


func _on_remove_database_button_pressed():
	remove_database_dialog.dialog_text = ("Remove '%s'?" % databases.get(current_database_id).label)
	remove_database_dialog.popup_centered()


func _on_remove_database_confirmation_dialog_confirmed():
	remove_database()


func _on_settings_button_pressed():
	settings_dialog.popup_centered()


func _on_edit_database_dialog_database_updated(data: ReactionDatabase):
	if databases.has(data.uid):
		var current_data = databases.get(data.uid)
		undo_redo.create_action("Set database data")
		undo_redo.add_do_method(self, "_remove_database_savefile", current_data)
		undo_redo.add_do_method(self, "set_database_data", data)
		undo_redo.add_undo_method(self, "set_database_data", current_data)
		undo_redo.add_undo_method(self, "_remove_database_savefile", data)
		undo_redo.commit_action()
	else:
		undo_redo.create_action("Set database data")
		undo_redo.add_do_method(self, "set_database_data", data)
		undo_redo.add_undo_method(self, "_remove_database", data.uid)
		undo_redo.add_do_method(self, "go_to_database", data.uid)
		undo_redo.add_undo_method(self, "go_to_database", current_database_id)
		undo_redo.commit_action()


func _on_database_menu_about_to_popup() -> void:
	build_databases_menu()


func _on_databases_menu_index_pressed(index):
	var popup = database_menu_button.get_popup()
	var label = popup.get_item_text(index)
	for database in databases.values():
		if database.label == label:
			undo_redo.create_action("Change database")
			undo_redo.add_do_method(self, "go_to_database", database.uid)
			undo_redo.add_undo_method(self, "go_to_database", current_database_id)
			undo_redo.commit_action()


func _on_setting_database_path_updated() -> void:
	load_databases_update_view()
