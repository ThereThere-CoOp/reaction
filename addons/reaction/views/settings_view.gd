@tool
extends VBoxContainer

signal databases_path_changed()

const ReactionSettings = preload("../utilities/settings.gd")

@onready var change_database_path_button: Button = %ChangeDatabasesPathButton
@onready var databases_path_lineedit: LineEdit = %DatabasesPathLineEdit
# dialogs
@onready var databases_path_dialog: FileDialog = %DatabasesFolderDialog


func _ready() -> void:
	call_deferred("apply_theme")
	
	# initializing settings control
	databases_path_lineedit.text = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)


func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(change_database_path_button):
		change_database_path_button.icon = get_theme_icon("Folder", "EditorIcons")


func _on_change_databases_path_button_pressed():
	databases_path_dialog.popup_centered()


func _on_databases_folder_dialog_dir_selected(dir: String):
	databases_path_lineedit.text = dir
	ReactionSettings.set_setting(ReactionSettings.DATABASES_PATH_SETTING_NAME, dir)
	databases_path_changed.emit()
