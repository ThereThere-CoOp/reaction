@tool
extends EditorPlugin

const MainView = preload("res://addons/reaction/views/main_view.tscn")

var main_view_instance

# autoloads vars
const AUTOLOADS_BASE_FOLDER = "res://addons/reaction/autoloads/"
const GLOBALS_SINGLETON_NAME = "ReactionGlobals"
const SIGNALS_SINGLETON_NAME = "ReactionSignals"


func _enable_plugin() -> void:
	add_autoload_singleton(GLOBALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_globals.tscn")
	add_autoload_singleton(SIGNALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_signals.tscn")
	
	_create_default_dirs()


func _disable_plugin() -> void:
	remove_autoload_singleton(GLOBALS_SINGLETON_NAME)
	remove_autoload_singleton(SIGNALS_SINGLETON_NAME)


func _enter_tree():
	
	if Engine.is_editor_hint():
		main_view_instance = MainView.instantiate()
		EditorInterface.get_editor_main_screen().add_child(main_view_instance)
		main_view_instance.undo_redo = get_undo_redo()
		main_view_instance.global_facts_panel.undo_redo = get_undo_redo()
		main_view_instance.global_facts_panel.facts_list.undo_redo = get_undo_redo()
		main_view_instance.events_panel.events_list.undo_redo = get_undo_redo()
		main_view_instance.rules_panel.rules_list.undo_redo = get_undo_redo()
		main_view_instance.responses_panel.responses_list.undo_redo = get_undo_redo()
		main_view_instance.tags_panel.tags_list.undo_redo = get_undo_redo()
		
		ReactionSettings.prepare()
		
		_create_default_dirs()
		
		_make_visible(false)


func _exit_tree():
	if main_view_instance:
		main_view_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_view_instance:
		main_view_instance.visible = visible


func _get_plugin_name() -> String:
	return "Reaction"


func _get_plugin_icon() -> Texture2D:
	return create_main_icon()
	
	
func _create_default_dirs() -> void:
	const REACTION_DEFAULTS_DIRS = [
		ReactionSettings.SQLITE_DATABASES_PATH_SETTING_NAME,
		ReactionSettings.EXPORT_PATH_SETTING_NAME,
		ReactionSettings.DIALOG_FILES_PATH_SETTING_NAME,
	]

	for default_dir_path in REACTION_DEFAULTS_DIRS:
		var default_path = ReactionSettings.get_setting(
			default_dir_path,
			ReactionSettings.SETTINGS_CONFIGURATIONS[default_dir_path].value
		)
		
		ReactionUtilities.create_folder_if_not_exists(default_path)


func create_main_icon(scale: float = 1.0) -> Texture2D:
	var size: Vector2 = Vector2(16, 16) * get_editor_interface().get_editor_scale() * scale
	var base_color: Color = get_editor_interface().get_editor_main_screen().get_theme_color("base_color", "Editor")
	var theme: String = "light" if base_color.v > 0.5 else "dark"
	var base_icon = load(get_script().resource_path.get_base_dir() + "/assets/icons/icon_main_view_%s.png" % theme) as Texture2D
	var image: Image = base_icon.get_image()
	image.resize(size.x, size.y, Image.INTERPOLATE_TRILINEAR)
	return ImageTexture.create_from_image(image)
