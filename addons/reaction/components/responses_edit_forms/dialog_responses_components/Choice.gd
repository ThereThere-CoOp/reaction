@tool
class_name Choice
extends ListObjectFormItem


@onready var label_line_edit: LineEdit = %LabelLineEdit
@onready var choice_text_line_edit: LineEdit = %ChoiceTextLineEdit
@onready var event_search_menu: SearchMenu = %EventSearchMenu

@onready var criterias_dialog: AcceptDialog = %CriteriasDialog
@onready var modifications_dialog: AcceptDialog = %ModificationsDialog

@onready var criterias_list: ListObjectForm = %Criterias
@onready var modifications_list: ListObjectForm = %Modifications


func _ready():
	super()
	remove_object_function_name = "remove_choice_by_index"
	object_name = "choice"
	
	label_line_edit.text = item_object.label
	if item_object.choice_text:
		choice_text_line_edit.text = item_object.choice_text
	
	event_search_menu.items_list = current_database.events.values()
	if item_object.triggers:
		event_search_menu.update_search_text_value(current_database.events[item_object.triggers].label)
	
	criterias_list.current_database = current_database
	criterias_list.setup_objects(item_object)
	modifications_list.current_database = current_database
	modifications_list.setup_objects(item_object)

### signals


func _on_label_line_edit_text_submitted(new_text):
	item_object.label = new_text
	current_database.save_data()


func _on_choice_text_line_edit_text_submitted(new_text):
	item_object.choice_text = new_text
	current_database.save_data()


func _on_event_search_menu_item_selected(item):
	item_object.triggers = item.uid
	current_database.save_data()


func _on_criterias_button_pressed():
	criterias_dialog.popup_centered()


func _on_modifications_button_pressed():
	modifications_dialog.popup_centered()
