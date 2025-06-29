@tool
extends MarginContainer

var current_response: ReactionResponseItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo


@onready var responses_list: ReactionUIItemList = %ResponsesList
@onready var response_data_container: MarginContainer = %ResponseDataContainer


# event inputs

func _ready() -> void:
	response_data_container.visible = false
	
	ReactionSignals.database_selected.connect(setup_responses)


func setup_responses() -> void:
	responses_list.setup_items()
	
	
func _set_response(response_data: ReactionResponseItem) -> void:
	current_response = response_data
	# set input default values
	response_data_container.visible = true
	
	
### signals

func _on_response_list_item_selected(item_data: ReactionResponseItem) -> void:
	_set_response(item_data)


func _on_responses_list_item_added(index, item_data):
	_set_response(item_data)


func _on_responses_list_item_removed(index, item_data):
	if responses_list.items_list.item_count > 0:
		_set_response(responses_list.current_item)
	else:
		response_data_container.visible = false


func _on_responses_list_item_list_updated():
	response_data_container.visible = false
