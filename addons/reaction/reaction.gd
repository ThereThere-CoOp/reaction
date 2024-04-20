@tool
extends EditorPlugin

const MainView = preload("res://addons/reaction/views/main_view.tscn")

var main_view_instance

# autoloads vars
const AUTOLOADS_BASE_FOLDER = "res://addons/reaction/autoloads/"
const GLOBALS_SINGLETON_NAME = "ReactionGlobals"
const SIGNALS_SINGLETON_NAME = "ReactionSignals"



func _enter_tree():
	if Engine.is_editor_hint():
		add_autoload_singleton(GLOBALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_globals.tscn")
		add_autoload_singleton(SIGNALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_signals.tscn")

		main_view_instance = MainView.instantiate()
		EditorInterface.get_editor_main_screen().add_child(main_view_instance)
		_make_visible(false)


func _exit_tree():
	remove_autoload_singleton(GLOBALS_SINGLETON_NAME)
	remove_autoload_singleton(SIGNALS_SINGLETON_NAME)

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


func create_main_icon(scale: float = 1.0) -> Texture2D:
	var size: Vector2 = Vector2(16, 16) * get_editor_interface().get_editor_scale() * scale
	var base_color: Color = get_editor_interface().get_editor_main_screen().get_theme_color("base_color", "Editor")
	var theme: String = "light" if base_color.v > 0.5 else "dark"
	var base_icon = load(get_script().resource_path.get_base_dir() + "/assets/icons/icon_main_view_%s.png" % theme) as Texture2D
	var image: Image = base_icon.get_image()
	image.resize(size.x, size.y, Image.INTERPOLATE_TRILINEAR)
	return ImageTexture.create_from_image(image)
