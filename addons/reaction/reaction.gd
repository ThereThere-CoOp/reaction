@tool
extends EditorPlugin

# autoloads vars
const AUTOLOADS_BASE_FOLDER = "res://addons/reaction/autoloads/"
const GLOBALS_SINGLETON_NAME = "ReactionGlobals"
const SIGNALS_SINGLETON_NAME = "ReactionSignals"



func _enter_tree():
	if Engine.is_editor_hint():
		add_autoload_singleton(GLOBALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_globals.tscn")
		add_autoload_singleton(SIGNALS_SINGLETON_NAME, AUTOLOADS_BASE_FOLDER + "reaction_signals.tscn")


func _exit_tree():
	remove_autoload_singleton(GLOBALS_SINGLETON_NAME)
	remove_autoload_singleton(SIGNALS_SINGLETON_NAME)
