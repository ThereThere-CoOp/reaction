@tool
class_name ReactionUIITextItem
extends VBoxContainer

const ReactionSettings = preload("../utilities/settings.gd")

var current_database: SQLite

var object: Resource

var texts_field_name: String

var paths_field_name: String

var code: String

var use_file: bool

@onready var language_label: Label = %LanguageLabel

@onready var text_edit: TextEdit = %TextEdit

@onready var dialog_file_container: HBoxContainer = %DialogFileContainer

@onready var open_file_link_button: LinkButton = %OpenFileLinkButton

@onready var edit_dialog_file_button: Button = %EditDialogFileButton

@onready var dialog_file_path_line_edit: LineEdit = %DialogFilePathLineEdit

@onready var dialog_file_dialog: FileDialog = %DialogFileDialog


func _change_component_visibility():
	use_file = object.use_file
	
	text_edit.visible = true
	dialog_file_container.visible = true
	open_file_link_button.visible = false
	if use_file:
		text_edit.visible = false
		var path = null
		var file_paths = object.get(paths_field_name)
		if file_paths:
			if code in file_paths:
				path = file_paths[code]
		if path and path != "":
			# temporally hidden
			# open_file_link_button.visible = true
			open_file_link_button.visible = false
	else:
		dialog_file_container.visible = false
		
		
func _update_component_data():
	var settings_language = ReactionSettings.get_setting(
		ReactionSettings.LANGUAGES_SETTING_NAME,
		ReactionSettings.LANGUAGES_SETTING_DEFAULT
	).duplicate()
	
	if code:
		language_label.text = settings_language[code]["name"]
		if not use_file:
			if code in object.get(texts_field_name):
				text_edit.text = object.get(texts_field_name)[code]
		else:
			var file_paths = object.get(paths_field_name)
			if file_paths:
				if code in file_paths:
					dialog_file_path_line_edit.text = file_paths[code]
		

func update():
	_change_component_visibility()
	_update_component_data()
	
	
func setup(parent: Resource, field_name: String, file_paths_field_name: String, current_code: String):
	current_database = ReactionGlobals.current_sqlite_database
	object = parent
	texts_field_name = field_name
	paths_field_name = file_paths_field_name
	code = current_code
	
	language_label = %LanguageLabel
	text_edit = %TextEdit
	dialog_file_container = %DialogFileContainer
	edit_dialog_file_button = %EditDialogFileButton
	dialog_file_path_line_edit = %DialogFilePathLineEdit
	dialog_file_dialog = %DialogFileDialog
	open_file_link_button = %OpenFileLinkButton
	
	var settings_dialog_files_path = ReactionSettings.get_setting(
		ReactionSettings.DEFAULT_DIALOG_FILES_PATH_SETTING_NAME,
		ReactionSettings.DIALOG_PATH_SETTING_DEFAULT
	)
	
	dialog_file_dialog.filters = ["*.txt", "*.dialogue"]
	dialog_file_dialog.root_subfolder = settings_dialog_files_path
	dialog_file_dialog.current_file = "%s_%s_%s.txt" % [object.uid, object.label, code]
	
	_change_component_visibility()
		
		
func _ready() -> void:
	_update_component_data()
	
	
func _update_file_path(path):
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string("")
		file.close()
		
		
	var texts_path_dict: Dictionary = object.get(paths_field_name).duplicate()
	texts_path_dict[code] = path
	dialog_file_path_line_edit.text = path
	object.set(paths_field_name, texts_path_dict)
	object.update_sqlite()
	
	ReactionSignals.created_dialog_file.emit(path)
	
## Signals


func _on_text_edit_text_changed() -> void:
	var texts_dict: Dictionary = object.get(texts_field_name).duplicate()
	texts_dict[code] = text_edit.text
	object.set(texts_field_name, texts_dict)
	object.update_sqlite()


func _on_edit_dialog_file_button_pressed() -> void:
	dialog_file_dialog.popup_centered()


func _on_dialog_file_dialog_file_selected(path: String) -> void:
	_update_file_path(path)
		
	
func _on_dialog_file_dialog_confirmed() -> void:
	var path = ''
	if dialog_file_dialog.current_file.get_basename() == "":
		path = "res://untitled.txt"
		
	_update_file_path(path)


func _on_open_file_link_button_pressed() -> void:
	var file_paths = object.get(paths_field_name)
	if file_paths:
		if code in file_paths:
			ReactionSignals.opened_dialog_file.emit(file_paths[code])
