@tool
extends VBoxContainer

signal databases_path_changed()

const ReactionSettings = preload("../utilities/settings.gd")

@onready var change_database_path_button: Button = %ChangeDatabasesPathButton
@onready var databases_path_lineedit: LineEdit = %DatabasesPathLineEdit

@onready var change_export_path_button: Button = %ChangeExportPathButton
@onready var export_path_lineedit: LineEdit = %ExportPathLineEdit

@onready var change_default_database_path_button: Button = %ChangeDefaultDatabasePathButton 
@onready var default_database_path_lineedit: LineEdit = %DefaultDatabasePathLineEdit

@onready var change_default_dialog_file_path_button: Button = %ChangeDefaultDialogFilesPathButton
@onready var default_dialog_files_path_lineedit: LineEdit = %DefaultDialogFilesPathLineEdit

# languages settings edit
@onready var languages_menu: MenuButton = %LanguagesMenuButton
@onready var add_language_button: Button =  %AddLanguageButton
@onready var remove_language_button: Button = %RemoveLanguageButton
@onready var language_name_edit: LineEdit = %LanguageNameLineEdit
@onready var language_code_edit: LineEdit = %LanguageCodeLineEdit

# dialogs
@onready var databases_path_dialog: FileDialog = %DatabasesFolderDialog
@onready var export_path_dialog: FileDialog = %ExportFolderDialog
@onready var default_database_path_dialog: FileDialog = %DefaultDatabaseFileDialog
@onready var default_dialog_files_path_dialog: FileDialog = %DialogFilesFolderDialog
@onready var languages_edit_dialog: ConfirmationDialog = %LanguagesEditConfirmationDialog
@onready var warning_dialog: AcceptDialog = %WarningAcceptDialog

var _current_selected_language_index = -1


func setup_settings() -> void:
	# initializing settings control
	databases_path_lineedit.text = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)
	
	export_path_lineedit.text = ReactionSettings.get_setting(
		ReactionSettings.EXPORT_PATH_SETTING_NAME,
		ReactionSettings.EXPORT_PATH_SETTING_DEFAULT
	)
	
	default_dialog_files_path_lineedit.text = ReactionSettings.get_setting(
		ReactionSettings.DEFAULT_DIALOG_FILES_PATH_SETTING_NAME,
		ReactionSettings.DIALOG_PATH_SETTING_DEFAULT
	)
	
	var default_database_path = ReactionSettings.get_setting(
		ReactionSettings.DEFAULT_DATABASE_PATH_SETTING_NAME,
		ReactionSettings.DEFAULT_DATABASE_PATH_SETTING_DEFAULT
	)
	default_database_path_lineedit.text = "No default database selected"
	if FileAccess.file_exists(default_database_path):
		default_database_path_lineedit.text = default_database_path
	
	var languages_popup_menu: PopupMenu = languages_menu.get_popup()
	
	var languages_dict = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	)
	
	languages_popup_menu.clear()
	var index = 0
	for languaje in languages_dict.values():
		languages_popup_menu.add_item(languaje["name"])
		languages_popup_menu.set_item_metadata(index, languaje["code"])
		index += 1
	
	_update_languages_menu_text()
	if not languages_popup_menu.index_pressed.is_connected(_on_languages_menu_popup_menu_index_pressed):
		languages_popup_menu.index_pressed.connect(_on_languages_menu_popup_menu_index_pressed)


func _ready() -> void:
	call_deferred("apply_theme")
	setup_settings()
	

func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(change_database_path_button):
		change_database_path_button.icon = get_theme_icon("Folder", "EditorIcons")
		change_default_database_path_button.icon = get_theme_icon("Folder", "EditorIcons")
		change_export_path_button.icon = get_theme_icon("Folder", "EditorIcons")
		change_default_dialog_file_path_button.icon = get_theme_icon("Folder", "EditorIcons")
		add_language_button.icon = get_theme_icon("New", "EditorIcons")
		remove_language_button.icon = get_theme_icon("Remove", "EditorIcons")
		

func _update_languages_menu_text() -> void:
	var result_text = ""
	
	var languages_dict = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	)
	
	for languaje in languages_dict.values():
		result_text += " %s," % languaje["name"]
		
	result_text = result_text.trim_suffix(",")
	languages_menu.text = result_text
	
	
### Sigals


func _on_change_databases_path_button_pressed():
	databases_path_dialog.popup_centered()


func _on_databases_folder_dialog_dir_selected(dir: String):
	databases_path_lineedit.text = dir
	ReactionSettings.set_setting(ReactionSettings.DATABASES_PATH_SETTING_NAME, dir)
	databases_path_changed.emit()
	
	
func _on_languages_menu_popup_menu_index_pressed(index: int) -> void:
	var languages_popup_menu: PopupMenu = languages_menu.get_popup()
	languages_menu.text = languages_popup_menu.get_item_text(index)
	_current_selected_language_index = index


func _on_add_language_button_pressed() -> void:
	languages_edit_dialog.popup_centered()


func _on_languages_edit_confirmation_dialog_confirmed() -> void:
	if language_name_edit.text == "" or language_code_edit.text == "":
		warning_dialog.dialog_text = "Must introduce a name and unique code for the language."
		warning_dialog.popup_centered()
		return
		
	var languages_dict = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	).duplicate()
	
	if language_code_edit.text.to_lower() in languages_dict:
		warning_dialog.dialog_text = "Language code must be unique."
		warning_dialog.popup_centered()
		return
	
	var new_language_dict = {}
	new_language_dict["name"] = language_name_edit.text
	new_language_dict["code"] = language_code_edit.text
	languages_dict[String(language_code_edit.text.to_lower())] = new_language_dict
	
	ReactionSettings.set_setting(ReactionSettings.LANGUAGES_SETTING_NAME, languages_dict)
	var languages_popup_menu: PopupMenu = languages_menu.get_popup()
	languages_popup_menu.add_item(language_name_edit.text)
	languages_popup_menu.set_item_metadata(languages_dict.size() - 1, language_code_edit.text )
	_update_languages_menu_text()


func _on_remove_language_button_pressed() -> void:
	if _current_selected_language_index != -1 and _current_selected_language_index != 0 and _current_selected_language_index != 1:
		var languages_popup_menu: PopupMenu = languages_menu.get_popup()
		var current_selected_language_code = languages_popup_menu.get_item_metadata(_current_selected_language_index)
		
		var languages_dict = ReactionSettings.get_setting(
			ReactionSettings.LANGUAGES_SETTING_NAME,
			ReactionSettings.LANGUAGES_SETTING_DEFAULT
		)
		languages_dict.erase(current_selected_language_code)
		languages_popup_menu.remove_item(_current_selected_language_index)
		_current_selected_language_index = -1
		ReactionSettings.set_setting(ReactionSettings.LANGUAGES_SETTING_NAME, languages_dict)
		_update_languages_menu_text()
	else:
		warning_dialog.dialog_text = "Cannot delete this language."
		warning_dialog.popup_centered()
		return


func _on_change_default_database_path_button_pressed():
	var databases_folder: String = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)
	
	default_database_path_dialog.root_subfolder = databases_folder
	default_database_path_dialog.popup_centered()


func _on_default_database_file_dialog_file_selected(path):
	var database := ResourceLoader.load(path)
	if database is ReactionDatabase:
		default_database_path_lineedit.text = path
		ReactionSettings.set_setting(ReactionSettings.DEFAULT_DATABASE_PATH_SETTING_NAME, path)
	else:
		warning_dialog.dialog_text = "File is not a reaction database."
		warning_dialog.popup_centered()


func _on_change_export_path_button_pressed() -> void:
	export_path_dialog.popup_centered()


func _on_export_folder_dialog_dir_selected(dir: String) -> void:
	export_path_lineedit.text = dir
	ReactionSettings.set_setting(ReactionSettings.EXPORT_PATH_SETTING_NAME, dir)


func _on_dialog_files_folder_dialog_dir_selected(dir: String) -> void:
	default_dialog_files_path_lineedit.text = dir
	ReactionSettings.set_setting(ReactionSettings.DEFAULT_DIALOG_FILES_PATH_SETTING_NAME, dir)


func _on_change_default_dialog_files_path_button_pressed() -> void:
	default_dialog_files_path_dialog.popup_centered()
