@tool
class_name MainResponseEditForm
extends PanelContainer

var current_database: ReactionDatabase

var current_response: ReactionResponseBaseItem
var current_tree_item: TreeItem


@onready var label_input_line_edit: LineEdit = %LabelInputLineEdit
@onready var uid_line_edit: LineEdit = %UidLineEdit
@onready var triggers_container: HBoxContainer = %TriggersContainer
@onready var events_search_menu: SearchMenu = %EventsSearchMenu


func _ready():
	label_input_line_edit.text = current_response.label
	uid_line_edit.text = current_response.uid
	
	# setup event search list
	if not current_response is ReactionResponseGroupItem:
		events_search_menu.items_list = current_database.events.values()
		if current_response.triggers:
			events_search_menu.update_search_text_value(current_database.events[current_response.triggers].label)
		
		triggers_container.visible = true
		events_search_menu.item_selected.connect(_on_label_events_search_menu_item_selected)
	
	
func setup(database: ReactionDatabase, response: ReactionResponseBaseItem, tree_item: TreeItem) -> void:
	current_database = database
	current_response = response
	current_tree_item = tree_item


###  signals


func _on_label_input_line_edit_text_submitted(new_text):
	if new_text != "":
		current_response.label = new_text
		current_tree_item.set_text(0, new_text)
		current_database.save_data()
		
		
func _on_label_events_search_menu_item_selected(item: Resource):
	current_response.triggers = item.uid
	current_database.save_data()
