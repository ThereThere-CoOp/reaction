@tool
class_name ReactionUIDialogText
extends ReactionUIListObjectFormItem


@export var show_event: bool = true
@export var show_criterias: bool = true
@export var show_modifications: bool = true

var label_line_edit: LineEdit
var texts_button: Button
var event_container: VBoxContainer
var event_search_menu: ReactionUISearchMenu
var texts: ReactionUIIText

var text_dialog: AcceptDialog
var criterias_dialog: AcceptDialog
var modifications_dialog: AcceptDialog

var criterias_button: Button
var modifications_button: Button

var criterias_list: ReactionUIListObjectForm
var modifications_list: ReactionUIListObjectForm
		
		
func setup(parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:	
	super(parent_object, object, index, is_new_object)
	label_line_edit = %LabelLineEdit
	texts_button = %TextButton
	event_container = %EventContainer
	event_search_menu = %EventSearchMenu
	texts = %Texts

	text_dialog = %TextDialog
	criterias_dialog = %CriteriasDialog
	modifications_dialog = %ModificationsDialog

	criterias_button = %CriteriasButton
	modifications_button = %ModificationsButton

	criterias_list = %Criterias
	modifications_list = %Modifications
	
	# remove_object_function_name = "remove_choice_by_index"
	# object_name = "choice"
	
	label_line_edit.text = item_object.label
	
	criterias_button.visible = show_criterias
	modifications_button.visible = show_modifications
	event_container.visible = show_event
	
	texts.setup(item_object)
	
	var event_resource = ReactionEventItem.get_new_object()
	event_search_menu.items_list = event_resource.get_sqlite_list(null, true)
	
	if show_event and item_object.triggers:
		var current_event_data = current_database.select_rows("event", "uid = '%s'" % [item_object.triggers], ["*"])
		if len(current_event_data) > 0:
			event_search_menu.update_search_text_value(current_event_data[0]["label"])
	
	criterias_list.setup_objects(item_object)
	modifications_list.setup_objects(item_object)
	
	criterias_list.object_added.connect(_on_criterias_object_added)
	modifications_list.object_added.connect(_on_modifications_object_added)
	
	criterias_list.object_removed.connect(_on_criterias_object_removed)
	modifications_list.object_removed.connect(_on_modifications_object_removed)
	
	_update_criterias_button_name()
	_update_modifications_button_name()
	

func _update_criterias_button_name() -> void:
	var resource = ReactionCriteriaItem.get_new_object()
	resource.parent_item = item_object
	var results = resource.get_sqlite_list()
	criterias_button.text = "Criterias (%d)" % results.size()

	
func _update_modifications_button_name() -> void:
	var resource = ReactionContextModificationItem.get_new_object()
	resource.parent_item = item_object
	var results = resource.get_sqlite_list()
	modifications_button.text = "Modifications (%d)" % results.size()
	
	
### signals


func _on_label_line_edit_text_submitted(new_text):
	item_object.label = new_text
	item_object.update_sqlite()


func _on_event_search_menu_item_selected(item):
	item_object.triggers = item.uid
	item_object.update_sqlite()


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
