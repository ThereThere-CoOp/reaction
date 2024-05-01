@tool
extends VBoxContainer

signal databases_path_changed()

const ReactionSettings = preload("../utilities/settings.gd")

@onready var databases_path_dialog: FileDialog = %DatabasesFolderDialog
@onready var databases_path_lineedit: LineEdit = %DatabasesPathLineEdit


func _ready() -> void:
	# initializing settings control
	databases_path_lineedit.text = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)


func _on_change_databases_path_button_pressed():
	databases_path_dialog.popup_centered()


func _on_databases_folder_dialog_dir_selected(dir: String):
	databases_path_lineedit.text = dir
	ReactionSettings.set_setting(ReactionSettings.DATABASES_PATH_SETTING_NAME, dir)
	databases_path_changed.emit()
