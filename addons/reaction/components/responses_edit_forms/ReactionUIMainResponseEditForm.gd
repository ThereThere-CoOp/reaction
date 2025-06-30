@tool
class_name ReactionUIMainResponseEditForm
extends PanelContainer

var sqlite_database: SQLite

var current_response: ReactionResponseBaseItem
var current_tree_item: TreeItem


@onready var label_input_line_edit: LineEdit = %LabelInputLineEdit
@onready var uid_line_edit: LineEdit = %UidLineEdit
@onready var triggers_container: HBoxContainer = %TriggersContainer
@onready var events_search_menu: ReactionUISearchMenu = %EventsSearchMenu


func _ready():
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
			events_search_menu.item_selected.connect(_on_label_events_search_menu_item_selected)
	
	
func setup(response: ReactionResponseBaseItem, tree_item: TreeItem) -> void:
	current_response = response
	# use signal to fix this
	current_tree_item = tree_item


###  signals


func _on_label_input_line_edit_text_submitted(new_text):
	if new_text != "":
		current_response.label = new_text
		# use signal to fix this
		# current_tree_item.set_text(0, new_text)
		current_response.update_sqlite()
		
		
func _on_label_events_search_menu_item_selected(item: Resource):
	current_response.triggers = item.uid
	current_response.update_sqlite()
