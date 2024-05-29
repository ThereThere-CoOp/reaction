@tool
extends VBoxContainer

signal item_added(index: int, item_data: Resource)

signal item_removed(index: int, item_data: Resource)

signal item_selected(item_data: Resource)

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var database_object: ReactionDatabase

var parent_object: Resource

var current_item: Resource

var current_item_index: int = -1

@export var item_name: String:
	set(new_name):
		item_name = new_name
		_processed_item_text = new_name.capitalize()
	get:
		return item_name

@export var item_list_field_name: String = "global_facts"
@export var item_name_field: String = "label"
@export var add_function_name: String = "add_fact"
@export var remove_function_name: String = "remove_fact"

@export var reaction_resource: Resource

@onready var item_label = %ItemLabel
@onready var items_list = %ItemList
@onready var add_item_button = %AddItemButton
@onready var remove_item_button = %RemoveItemButton
@onready var item_searcher_edit: LineEdit = %ItemSearcher

var _processed_item_text: String


func _ready():
	item_label.text = "%ss:" % _processed_item_text
	add_item_button.text = "Add %s" % _processed_item_text
	remove_item_button.text = "Remove %s" % _processed_item_text
	item_searcher_edit.placeholder_text = "Search by %s's name" % _processed_item_text

	if not items_list.is_anything_selected():
		remove_item_button.disabled = true
		
	ReactionSignals.connect("database_selected", _on_database_selected)


func setup_items(new_parent_object: Resource) -> void:
	items_list.clear()
	remove_item_button.disabled = true
	
	parent_object = new_parent_object
	var tmp_item_list = []
	if parent_object.get(item_list_field_name) is Dictionary:
		tmp_item_list = parent_object.get(item_list_field_name).values()
	else:
		tmp_item_list = parent_object.get(item_list_field_name)
		
	for item in tmp_item_list:
		var index = items_list.add_item(item.get(item_name_field))
		items_list.set_item_metadata(index, item)


func _select_item(index: int, is_emit_signal: bool = true) -> void:
	current_item = items_list.get_item_metadata(index)
	current_item_index = index
	items_list.select(index)

	if is_emit_signal:
		item_selected.emit(current_item)

	remove_item_button.disabled = false


func _add_item(item: Resource, index_to_add: int = -1) -> void:
	var add_function_callable = Callable(parent_object, add_function_name)
	add_function_callable.call(item)
	database_object.save_data()
	var index = items_list.add_item(item.get(item_name_field))
	items_list.set_item_metadata(index, item)

	if index_to_add != -1:
		items_list.move_item(index, index_to_add)
		index = index_to_add

	_select_item(index, false)
	item_added.emit(index, item)


func _remove_item(item: Resource, index: int) -> void:
	var remove_function_callable = Callable(parent_object, remove_function_name)
	remove_function_callable.call(item.uid)
	database_object.save_data()
	items_list.remove_item(index)

	if parent_object.get(item_list_field_name).size() == 0:
		current_item_index = -1
		remove_item_button.disabled = true
		items_list.deselect_all()
	else:
		if current_item_index >=  parent_object.get(item_list_field_name).size():
			current_item_index =  parent_object.get(item_list_field_name).size() - 1
			current_item = items_list.get_item_metadata(current_item_index)
		else:
			current_item_index -= 1
			current_item_index = max(0, current_item_index)
			current_item = items_list.get_item_metadata(current_item_index)

		_select_item(current_item_index, false)

	item_removed.emit(index, item)


### signals


func _on_database_selected(database: ReactionDatabase) -> void:
	database_object = database


func _on_item_list_item_selected(index):
	undo_redo.create_action("Selected %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_select_item", index)
	if current_item_index != -1:
		undo_redo.add_undo_method(self, "_select_item", current_item_index)
	undo_redo.commit_action()


func _on_add_item_button_pressed():
	var new_item = reaction_resource.get_new_object()
	undo_redo.create_action("Add %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_add_item", new_item)
	undo_redo.add_undo_method(self, "_remove_item", new_item, parent_object.get(item_list_field_name).size())
	undo_redo.commit_action()


func _on_remove_item_button_pressed():
	undo_redo.create_action("Remove  %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_remove_item", current_item, current_item_index)
	undo_redo.add_undo_method(self, "_add_item", current_item, current_item_index)
	undo_redo.commit_action()
