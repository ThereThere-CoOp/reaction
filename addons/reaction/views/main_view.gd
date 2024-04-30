@tool
extends Control

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
@onready var database_managment_panel = %DatabaseDataManagment


func _ready() -> void:
	call_deferred("apply_theme")


func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(add_database_button):
		add_database_button.icon = get_theme_icon("New", "EditorIcons")
		database_menu_button.icon = get_theme_icon("Script", "EditorIcons")
		edit_database_button.icon = get_theme_icon("Edit", "EditorIcons")
		remove_database_button.icon = get_theme_icon("Remove", "EditorIcons")
		settings_button.icon = get_theme_icon("Tools", "EditorIcons")


func go_to_database(id: String) -> void:
	if ReactionGlobals.current_database_uid != id:
		# save_board()

		ReactionGlobals.current_database_uid = id
		# PuzzleSettings.set_setting("current_board_id", id)

		if ReactionGlobals.databases.has(ReactionGlobals.current_database_uid):
			var database_data = ReactionGlobals.databases.get(ReactionGlobals.current_database_uid)
			# board.from_serialized(board_data)

	if ReactionGlobals.current_database_uid == "":
		database_managment_panel.hide()
		edit_database_button.disabled = true
		remove_database_button.disabled = true
	else:
		database_managment_panel.show()
		edit_database_button.disabled = false
		remove_database_button.disabled = false

	build_databases_menu()


func _on_main_view_theme_changed() -> void:
	apply_theme()


func build_databases_menu() -> void:
	var menu: PopupMenu = database_menu_button.get_popup()
	menu.clear()

	if menu.index_pressed.is_connected(_on_databases_menu_index_pressed):
		menu.index_pressed.disconnect(_on_databases_menu_index_pressed)

	if ReactionGlobals.databases.size() == 0:
		database_menu_button.text = "No databases yet"
		database_menu_button.disabled = true
	else:
		database_menu_button.disabled = false

		# Add databases labels to the menu in alphabetical order
		var labels := []
		for database in ReactionGlobals.databases.values():
			labels.append(database.name)
		labels.sort()
		for label in labels:
			menu.add_icon_item(get_theme_icon("Script", "EditorIcons"), label)

		if ReactionGlobals.databases.has(ReactionGlobals.current_database_uid):
			database_menu_button.text = (
				ReactionGlobals.databases.get(ReactionGlobals.current_database_uid).name
			)
		menu.index_pressed.connect(_on_databases_menu_index_pressed)


### signals

func _on_database_menu_about_to_popup() -> void:
	build_databases_menu()


func _on_databases_menu_index_pressed(index):
	var popup = database_menu_button.get_popup()
	var label = popup.get_item_text(index)
	for database in ReactionGlobals.databases.values():
		if database.name == label:
			undo_redo.create_action("Change database")
			undo_redo.add_do_method(self, "go_to_database", database.uid)
			undo_redo.add_undo_method(self, "go_to_database", ReactionGlobals.current_database_uid)
			undo_redo.commit_action()
