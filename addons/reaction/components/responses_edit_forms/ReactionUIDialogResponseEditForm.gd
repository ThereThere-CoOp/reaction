@tool
class_name ReactionUIDialogResponseEditForm
extends ReactionUIMainResponseEditForm


@onready var dialog_texts_list: ReactionUIListObjectForm = %DialogTextsList

@onready var choices_container: ReactionUIListObjectForm = %ChoicesList
@onready var has_choices_check_button: CheckButton = %HasChoicesCheckButton


func _ready():
	super()
	
	call_deferred("apply_theme")
	
	if current_response:
		
		dialog_texts_list.current_database = current_database
		dialog_texts_list.setup_objects(current_response)
		
		choices_container.current_database = current_database
		choices_container.setup_objects(current_response)
		has_choices_check_button.set_pressed_no_signal(current_response.have_choices)
		choices_container.visible = current_response.have_choices
	
	
func apply_theme() -> void:
	# Simple check if onready
	pass
	

### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_has_choices_check_button_toggled(toggled_on):
	current_response.have_choices = toggled_on
	current_database.save_data()
	choices_container.visible = toggled_on
