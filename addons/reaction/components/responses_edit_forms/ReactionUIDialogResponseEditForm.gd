@tool
class_name ReactionUIDialogResponseEditForm
extends ReactionUIMainResponseEditForm


@onready var dialog_texts_list: ReactionUIListObjectForm = %DialogTextsList

@onready var choices_container: ReactionUIListObjectForm = %ChoicesList
@onready var has_choices_check_button: CheckButton = %HasChoicesCheckButton


func _setup_dialog_panel():
	if current_response:
		var texts_where = ""
		for obj in dialog_texts_list.objects_to_add_data_array:
			var resource = obj.object_resource_class.get_new_object()
			texts_where += "rule.reaction_item_type = %d OR" % [resource.reaction_item_type]
			
		var choice_where = ""
		for obj in choices_container.objects_to_add_data_array:
			var resource = obj.object_resource_class.get_new_object()
			choice_where += "rule.reaction_item_type = %d OR" % [resource.reaction_item_type]
			
		texts_where = texts_where.trim_suffix(" OR")
		choice_where = choice_where.trim_suffix(" OR")
		

		dialog_texts_list.setup_objects(current_response, texts_where)
		# dialog_texts_list.call_deferred("setup_objects", current_response, texts_where)
		
		choices_container.setup_objects(current_response, choice_where)
		# choices_container.call_deferred("setup_objects", current_response, choice_where)
		has_choices_check_button.set_pressed_no_signal(current_response.have_choices)
		choices_container.visible = current_response.have_choices


func setup(response: ReactionResponseBaseItem):
	super(response)
	
	dialog_texts_list = %DialogTextsList
	choices_container = %ChoicesList
	has_choices_check_button = %HasChoicesCheckButton
	_setup_dialog_panel()
		
		
func _ready():
	call_deferred("apply_theme")
	

func apply_theme() -> void:
	# Simple check if onready
	pass
	

### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_has_choices_check_button_toggled(toggled_on):
	current_response.have_choices = toggled_on
	current_response.update_sqlite()
	choices_container.visible = toggled_on
