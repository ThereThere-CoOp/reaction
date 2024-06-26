@tool
class_name ResponseGroupEditForm
extends MainResponseEditForm


@onready var dialog_text_edit: TextEdit = %DialogTextEdit
@onready var save_text_button: Button = %SaveTextButton

@onready var choices_container: ListObjectForm = %ChoicesList
@onready var has_choices_check_button: CheckButton = %HasChoicesCheckButton


func _ready():
	super()
	
	call_deferred("apply_theme")
	
	if current_response.dialog_text:
		dialog_text_edit.text = current_response.dialog_text
	
	choices_container.current_database = current_database
	choices_container.setup_objects(current_response)
	has_choices_check_button.set_pressed_no_signal(current_response.have_choices)
	choices_container.visible = current_response.have_choices
	
	
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


func _on_has_choices_check_button_toggled(toggled_on):
	current_response.have_choices = toggled_on
	current_database.save_data()
	choices_container.visible = toggled_on
