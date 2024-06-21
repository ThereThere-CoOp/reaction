@tool
extends MarginContainer


var current_database: ReactionDatabase

var current_event: ReactionEventItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo


@onready var events_list: VBoxContainer = %EventsList
@onready var event_data_container: VBoxContainer = %EventDataContainer
@onready var rules_panel = %Rules

# event inputs
@onready var event_name_input: LineEdit = %EventNameLineEdit
@onready var event_uid_input: LineEdit = %EventUidLineEdit
@onready var event_tags_input: ReactionUIMultiselect = %EventTabsMultiselect

func _ready() -> void:
	event_data_container.visible = false
	
	ReactionSignals.database_selected.connect(setup_events)


func setup_events(database: ReactionDatabase) -> void:
	current_database = database
	events_list.setup_items(current_database)
	
	
func _set_event(event_data: ReactionEventItem) -> void:
	current_event = event_data
	# set input default values
	event_name_input.text = current_event.label
	event_uid_input.text = current_event.uid
	
	rules_panel.setup_rules(current_event)
	rules_panel.current_event = current_event
	rules_panel.rule_data_container.visible = false
	event_data_container.visible = true
	event_tags_input.setup(current_event, current_database.tags.values())


func _set_event_property(property_name: StringName, value: Variant) -> void:
	current_event.set(property_name, value)
	current_database.save_data()
	
	
### signals

func _on_events_list_item_selected(item_data: ReactionEventItem) -> void:
	_set_event(item_data)


func _on_event_name_input_line_edit_text_submitted(new_text: String) -> void:
	_set_event_property("label", new_text)
	events_list.items_list.set_item_text(events_list.current_item_index, new_text)
	
func _on_events_list_item_added(index, item_data):
	_set_event(item_data)


func _on_events_list_item_removed(index, item_data):
	if current_database.events.size() > 0:
		_set_event(events_list.current_item)
	else:
		event_data_container.visible = false
