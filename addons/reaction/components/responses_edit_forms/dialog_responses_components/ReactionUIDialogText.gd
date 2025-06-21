@tool
class_name ReactionUIDialogText
extends ReactionUIListObjectFormItem


@export var show_event: bool = true
@export var show_criterias: bool = true
@export var show_modifications: bool = true

@onready var label_line_edit: LineEdit = %LabelLineEdit
@onready var texts_button: Button = %TextButton
@onready var event_container: VBoxContainer = %EventContainer
@onready var event_search_menu: ReactionUISearchMenu = %EventSearchMenu
@onready var texts: ReactionUIIText = %Texts

@onready var text_dialog: AcceptDialog = %TextDialog
@onready var criterias_dialog: AcceptDialog = %CriteriasDialog
@onready var modifications_dialog: AcceptDialog = %ModificationsDialog

@onready var criterias_button: Button = %CriteriasButton
@onready var modifications_button: Button = %ModificationsButton

@onready var criterias_list: ReactionUIListObjectForm = %Criterias
@onready var modifications_list: ReactionUIListObjectForm = %Modifications


func _ready():
	super()
	if item_object:
		# remove_object_function_name = "remove_choice_by_index"
		# object_name = "choice"
		
		label_line_edit.text = item_object.label
		
		criterias_button.visible = show_criterias
		modifications_button.visible = show_modifications
		event_container.visible = show_event
		
		texts.setup(item_object)
		
		event_search_menu.items_list = current_database.events.values()
		
		if show_event and item_object.triggers:
			event_search_menu.update_search_text_value(current_database.events[item_object.triggers].label)
		
		criterias_list.current_database = current_database
		criterias_list.setup_objects(item_object)
		modifications_list.current_database = current_database
		modifications_list.setup_objects(item_object)
		
		_update_criterias_button_name()
		_update_modifications_button_name()


func _update_criterias_button_name() -> void:
	criterias_button.text = "Criterias (%d)" % item_object.criterias.size()

	
func _update_modifications_button_name() -> void:
	modifications_button.text = "Modifications (%d)" % item_object.modifications.size()
	
	
### signals


func _on_label_line_edit_text_submitted(new_text):
	item_object.label = new_text
	current_database.save_data()


func _on_event_search_menu_item_selected(item):
	item_object.triggers = item.uid
	current_database.save_data()


func _on_criterias_button_pressed():
	criterias_dialog.popup_centered()


func _on_modifications_button_pressed():
	modifications_dialog.popup_centered()


func _on_criterias_object_added(object: Resource) -> void:
	_update_criterias_button_name()
	

func _on_modifications_object_added(object: Resource) -> void:
	_update_modifications_button_name()


func _on_criterias_object_removed() -> void:
	_update_criterias_button_name()


func _on_modifications_object_removed() -> void:
	_update_modifications_button_name()


func _on_choice_text_button_pressed() -> void:
	text_dialog.popup_centered()
