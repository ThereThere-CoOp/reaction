@tool
class_name ReactionUIItemList
extends VBoxContainer

signal item_list_updated()

signal item_added(index: int, item: Resource)

signal item_removed(index: int, item: Resource)

signal item_selected(item: Resource)

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var current_parent_item: Resource

var current_item: Resource

var current_item_index: int = -1

@export var item_name: String:
	set(new_name):
		item_name = new_name
		_processed_item_text = new_name.capitalize()
	get:
		return item_name

@export var sqlite_tag_table_name: String = "tag"
@export var item_name_field: String = "label"


@export var reaction_resource: Resource

@export var objects_to_add_data_array: Array[ListObjectFormObjectToAdd] = []

@onready var item_label = %ItemLabel
@onready var items_list = %ItemList
@onready var add_item_menu_button: MenuButton = %AddItemMenuButton
@onready var remove_item_button = %RemoveItemButton

@onready var item_searcher_edit: LineEdit = %ItemSearcher
@onready var tag_filter_button: Button = %TagFilterButton
@onready var clear_filter_button: Button = %ClearFilterButton
@onready var filter_accept_dialog: AcceptDialog = %FilterAcceptDialog
@onready var tag_filter_item_list: ItemList = %TagFilterItemList
@onready var tag_filter_label: Label = %FilterInformationLabel

@onready var warning_dialog: AcceptDialog = %WarningAcceptDialog

var _sqlite_database: SQLite
var _processed_item_text: String

var _all_item_list = []
var _current_item_list = []


func _ready():
	call_deferred("apply_theme")
	
	item_label.text = "%ss:" % _processed_item_text
	add_item_menu_button.text = "Add %s" % _processed_item_text
	
	remove_item_button.text = "Remove %s" % _processed_item_text
	item_searcher_edit.placeholder_text = "Search by %s's name" % _processed_item_text
	
	var add_item_menu_button_popup: Popup = add_item_menu_button.get_popup()
	
	for object_data: ListObjectFormObjectToAdd in objects_to_add_data_array:
		add_item_menu_button_popup.add_item("Add %s" % object_data.object_name)


	if not items_list.is_anything_selected():
		remove_item_button.disabled = true
		
	ReactionSignals.database_selected.connect(_on_database_selected)
	add_item_menu_button_popup.index_pressed.connect(_on_add_item_popup_index_pressed)
	
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(clear_filter_button):
		tag_filter_button.icon = get_theme_icon("AnimationFilter", "EditorIcons")
		clear_filter_button.icon = get_theme_icon("Clear", "EditorIcons")


func _update_item_list() -> void:
	items_list.clear()
	items_list.deselect_all()
	
	for item in _current_item_list:
		var index = items_list.add_item(item.get(item_name_field))
		items_list.set_item_metadata(index, item)
		
	item_list_updated.emit()
	
	
func _update_tag_list():
	tag_filter_item_list.clear()
	tag_filter_item_list.deselect_all()
	
	var tags = _sqlite_database.select_rows(sqlite_tag_table_name, "", ["*"])
	
	for tag in tags:
		var index = tag_filter_item_list.add_item(tag.get(item_name_field))
		tag_filter_item_list.set_item_metadata(index, tag)
		
		
func setup_items(parent_item: Resource = null) -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database
	remove_item_button.disabled = true
	
	_all_item_list.clear()
	
	var tmp_item = reaction_resource.get_new_object()
	current_parent_item = parent_item
	tmp_item.parent_item = parent_item
	var objects_list = tmp_item.get_sqlite_list(null, false)
	
	for object_data in objects_list:
			var current_resource = _get_resource_from_type(object_data.get("reaction_item_type"))
			var reaction_item = current_resource.get_new_object()
			reaction_item.deserialize(object_data)
			_all_item_list.append(reaction_item)
	
	_current_item_list = _all_item_list
	
	
	_update_tag_list()
	_update_item_list()
	
	
func _select_item(index: int, is_emit_signal: bool = true) -> void:
	current_item = items_list.get_item_metadata(index)
	current_item_index = index
	items_list.select(index)

	if is_emit_signal:
		item_selected.emit(current_item)

	remove_item_button.disabled = false
	
	
func _get_resource_from_type(type: int) -> ReactionBaseItem:
	for resource in objects_to_add_data_array:
		if type == resource.object_resource_class.reaction_item_type:
			return resource.object_resource_class
			
	return null


func _add_item(item: Resource, index_to_add: int = -1) -> void:
	item.parent_item = current_parent_item
	item.add_to_sqlite()
	var index = items_list.add_item(item.get(item_name_field))
	items_list.set_item_metadata(index, item)
	
	_current_item_list.append(item)
	_all_item_list.append(item)

	if index_to_add != -1:
		items_list.move_item(index, index_to_add)
		index = index_to_add

	_select_item(index, false)
	item_added.emit(index, item)


func _remove_item(item: Resource, index: int) -> void:
	if current_item.has_method("get_references"):
		if current_item.get_references().size() != 0:
			warning_dialog.dialog_text = "The item have references. You cannot delete it."
			warning_dialog.popup_centered()
			return
	
	item.remove_from_sqlite()
	
	items_list.remove_item(index)
	
	_current_item_list.erase(current_item)
	_all_item_list.erase(current_item)
	
	if _current_item_list.size() == 0:
		current_item_index = -1
		remove_item_button.disabled = true
		items_list.deselect_all()
	else:
		if current_item_index >=  _current_item_list.size():
			current_item_index =  _current_item_list.size() - 1
			current_item = items_list.get_item_metadata(current_item_index)
		else:
			current_item_index -= 1
			current_item_index = max(0, current_item_index)
			current_item = items_list.get_item_metadata(current_item_index)

		_select_item(current_item_index, false)

	item_removed.emit(index, item)
	
	
func _update_filter_label_text(new_text: String) -> void:
	if tag_filter_label.text == "No filter activated":
		tag_filter_label.text = new_text
		tag_filter_label.tooltip_text = new_text
	else:
		tag_filter_label.text += new_text
		tag_filter_label.tooltip_text = new_text


### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_database_selected() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database


func _on_item_list_item_selected(index):
	undo_redo.create_action("Selected %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_select_item", index)
	
	if current_item_index != -1:
		undo_redo.add_undo_method(self, "_select_item", current_item_index)
	undo_redo.commit_action()


func _on_add_item_popup_index_pressed(index: int):
	var object_data: ListObjectFormObjectToAdd = objects_to_add_data_array[index]
	var new_item = object_data.object_resource_class.get_new_object()

	undo_redo.create_action("Add %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_add_item", new_item)
	undo_redo.add_undo_method(self, "_remove_item", new_item, _all_item_list.size() - 1)
	undo_redo.commit_action()


func _on_remove_item_button_pressed():
	undo_redo.create_action("Remove  %s" % _processed_item_text)
	undo_redo.add_do_method(self, "_remove_item", current_item, current_item_index)
	undo_redo.add_undo_method(self, "_add_item", current_item, current_item_index)
	undo_redo.commit_action()


func _on_item_searcher_text_submitted(new_text: String):
	var result = []
	var search_input = new_text.to_lower()
	for item in _current_item_list:
		if item.get(item_name_field).to_lower().contains(search_input):
			result.append(item)
			
	_current_item_list = result
	item_searcher_edit.text = ""
	var filter_label_text = " ( name like '%s')" % new_text
	_update_filter_label_text(filter_label_text)
	_update_item_list()
		

func _on_clear_filter_button_pressed():
	_current_item_list.clear()
	_current_item_list = _all_item_list
	tag_filter_label.text = "No filter activated"
	_update_item_list()
	
	
# not a very efficient search function
func _on_filter_accept_dialog_confirmed():
	var selected_indexes = tag_filter_item_list.get_selected_items()
	var result = []
	var filter_label_text = ""
	for index in selected_indexes:
		var tag = tag_filter_item_list.get_item_metadata(index)
		filter_label_text += " (tag = '%s')" % tag.label
		
		for item in _current_item_list:
			var item_tags = item.get_tags()
			if result.find_custom(func(i): return i.get("uid") == item.uid) == -1 and item_tags.find_custom(func(i): return i.get("id") == tag.id) != -1:
				result.append(item)
				
	_current_item_list = result
	_update_filter_label_text(filter_label_text)
	_update_item_list()


func _on_tag_filter_button_pressed():
	_update_tag_list()
	filter_accept_dialog.popup_centered()
