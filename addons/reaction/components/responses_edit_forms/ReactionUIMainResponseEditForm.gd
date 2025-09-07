@tool
class_name ReactionUIMainResponseEditForm
extends PanelContainer

signal field_updated()

var sqlite_database: SQLite

var current_response: ReactionResponseBaseItem


@onready var label_input_line_edit: LineEdit = %LabelInputLineEdit
@onready var uid_line_edit: LineEdit = %UidLineEdit
@onready var triggers_container: HBoxContainer = %TriggersContainer
@onready var events_search_menu: ReactionUISearchMenu = %EventsSearchMenu

@onready var resource_file_dialog: FileDialog = %ResourceFileDialog
@onready var resource_path_linedit: LineEdit = %ResourcePathLineEdit
@onready var resource_path_choose_button: Button = %ResourcePathChooseButton
@onready var clean_resource_path_button: Button = %CleanResourceButton
		
		
func _setup_panel():
	if current_response:
		sqlite_database = ReactionGlobals.current_sqlite_database
		label_input_line_edit.text = current_response.label
		uid_line_edit.text = current_response.uid
		
		# setup event search list
		if not current_response is ReactionResponseGroupItem:
			var events_list = ReactionEventItem.new().get_sqlite_list(null, true)
			events_search_menu.items_list = events_list
			if current_response.triggers:
				var trigger_event = events_list.filter(func(e): return e.uid == current_response.triggers).front()
				events_search_menu.update_search_text_value(trigger_event.label)
			
			triggers_container.visible = true
			if not events_search_menu.is_connected("item_selected", _on_label_events_search_menu_item_selected):
				events_search_menu.item_selected.connect(_on_label_events_search_menu_item_selected)
				
			if current_response.resource != null:
				resource_path_linedit.text = current_response.resource
	
func setup(response: ReactionResponseBaseItem) -> void:
	current_response = response
	# use signal to fix this
	
	label_input_line_edit = %LabelInputLineEdit
	uid_line_edit = %UidLineEdit
	triggers_container = %TriggersContainer
	events_search_menu = %EventsSearchMenu
	resource_file_dialog = %ResourceFileDialog
	resource_path_linedit = %ResourcePathLineEdit
	resource_path_choose_button = %ResourcePathChooseButton
	clean_resource_path_button = %CleanResourceButton
	
	_setup_panel()
	
	
###  signals


func _on_label_input_line_edit_text_submitted(new_text):
	if new_text != "":
		current_response.label = new_text
		current_response.update_sqlite()
		field_updated.emit("label", new_text)
		
		
func _on_label_events_search_menu_item_selected(item: Resource):
	current_response.triggers = item.uid
	current_response.update_sqlite()


func _on_resource_path_choose_button_pressed() -> void:
	resource_file_dialog.popup_centered()


func _on_resource_file_dialog_file_selected(path: String) -> void:
	resource_path_linedit.text = path
	current_response.resource = path
	current_response.update_sqlite()


func _on_clean_resource_button_pressed() -> void:
	resource_path_linedit.text = ""
	current_response.resource = ""
	current_response.update_sqlite()
