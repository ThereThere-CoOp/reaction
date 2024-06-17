@tool
class_name ResponseGroupEditForm
extends MainResponseEditForm


@onready var dialog_text_edit: TextEdit = %DialogTextEdit
@onready var save_text_button: Button = %SaveTextButton

@onready var choices_container: ListObjectForm = %Choices


func _ready():
	super()
	
	call_deferred("apply_theme")
	
	if current_response.dialog_text:
		dialog_text_edit.text = current_response.dialog_text
	
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(save_text_button):
		save_text_button.icon = get_theme_icon("Save", "EditorIcons")
	

### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_save_text_button_pressed():
	current_response.dialog_text = dialog_text_edit.text
	current_database.save_data()
	save_text_button.disabled = true


func _on_dialog_text_edit_text_changed():
	if dialog_text_edit.text and dialog_text_edit.text != "":
		save_text_button.disabled = false
