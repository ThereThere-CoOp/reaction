@tool
class_name ReactionUIMultiselect
extends MarginContainer

var objects_list = []

var parent_object: ReactionBaseItem

@export var object_name: String = "tag"

@export var related_object_table_name: String = "tag"

@export var relation_table_name: String = "tag_item_rel"

@export var parent_field_name: String = "fact_id"

@export var related_field_name: String = "tag_id"

@export var list_object_label_field_name: String = "label"

@onready var selected_button: Button = %SelectedButton
@onready var list_dialog: AcceptDialog = %ListAcceptDialog
@onready var item_list: ItemList = %ItemList

var _sqlite_database: SQLite

func _ready() -> void:
	list_dialog.title = "Select %s(s)" % object_name
	ReactionSignals.database_selected.connect(_on_database_selected)


func _get_related_objects_list() -> Array:
	var where = "%s = %d" % [parent_field_name, parent_object.sqlite_id]
	
	var related_relation_query_field_name = "%s.%s" % [relation_table_name, related_field_name]
	var parent_relation_query_field_name = "%s.%s" % [relation_table_name, parent_field_name]
		
	var query = """
	SELECT * FROM %s 
	INNER JOIN %s ON %s.id = %s
	WHERE %s = %d;
	""" % [related_object_table_name, relation_table_name, related_object_table_name, related_relation_query_field_name, parent_relation_query_field_name, parent_object.sqlite_id]
	
	_sqlite_database.query(query)
	var result = _sqlite_database.query_result
	
	return result
	
	
func _update_selected_button_text() -> void:
	var current_objects = _get_related_objects_list()
	var result_text = "Select %s(s)" % object_name 
	if current_objects.size() > 0:
		result_text = ""
		for object in current_objects:
			result_text += "%s, " % object.get(list_object_label_field_name)
			
		result_text = result_text.trim_suffix(", ")
		
	selected_button.text = result_text
	selected_button.tooltip_text = result_text
	
	
func _reselect_items() -> void:
	item_list.deselect_all()
	for rel_obj in _get_related_objects_list():
		var index = -1
		var current_index = 0
		for object in objects_list:
			if object.get("id") == rel_obj.get(related_field_name):
				index = current_index
				break
			
			current_index += 1
		
		if index != -1:
			item_list.select(index, false)
			
			
func _update_objects_list():
	objects_list = _sqlite_database.select_rows(related_object_table_name, "", ["*"])
	
	item_list.clear()
	for obj in objects_list:
		var current_index = item_list.add_item(obj.get(list_object_label_field_name))
		item_list.set_item_metadata(current_index, obj)

func setup(object: Resource) -> void:
	parent_object = object
	
	_update_objects_list()
	_reselect_items()
	_update_selected_button_text()


### signals

func _on_database_selected() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database
	

func _on_selected_button_pressed():
	_update_objects_list()
	_reselect_items()
	list_dialog.popup_centered()
	
	
func _get_array_str(array: Array) -> String:
	var result = ""
	for value in array:
		result += "%s," % [str(value)]
		
	return result.trim_suffix(",")
	

func _on_list_accept_dialog_confirmed():
	var selected_indexes = item_list.get_selected_items()
	var related_objects = _get_related_objects_list()
	
	var ids_to_add: Array[int] = []
	var ids_to_delete:  Array[int] = []
	var selected_ids: Array[int] = []
	var related_ids: Array[int] = []
	
	for ind in selected_indexes:
		var selected_id = item_list.get_item_metadata(ind).get("id")
		selected_ids.append(selected_id)
		
	for related_obj in related_objects:
		var related_id = related_obj.get(related_field_name)
		related_ids.append(related_id)
		
		if selected_ids.find(related_id) == -1:
			ids_to_delete.append(related_id)
			
	for selected_id in selected_ids:
		if related_ids.find(selected_id) == -1:
			ids_to_add.append(selected_id)
	
	if ids_to_delete.size() > 0:
		var where_in_array_str = _get_array_str(ids_to_delete)
		var delete_where = "%s IN (%s) AND %s = %d" % [related_field_name, where_in_array_str, parent_field_name, parent_object.sqlite_id]
		
		_sqlite_database.delete_rows(relation_table_name, delete_where)
	
	var rows_data_to_add = []
	
	if ids_to_add.size() > 0:
		for id in ids_to_add:
			var current_data = {}
			current_data[related_field_name] = id
			current_data[parent_field_name] = parent_object.sqlite_id
			rows_data_to_add.append(current_data)
		
		_sqlite_database.insert_rows(relation_table_name, rows_data_to_add)
	
	_update_selected_button_text()
