@tool
class_name ReactionBaseItem
extends Resource
## ----------------------------------------------------------------------------[br]
## Base parent resource class for reaction items.
##
## A base class for reaction items like facts, rules, concepts and responses.
## Contains common fields and functions for reaction items. [br]
## --------------------------------------------------------------------------------

@export_group("Reaction item general data")
@export var uid: String = Uuid.v4()

@export var label: String = "item_label"
@export_multiline var description: String = "Item long description"

@export_enum("Global", "Event") var scope: String = "Global"

@export var reaction_item_type: int

@export var tags: Array[ReactionTagItem]: 
	set(value):
		if self is ReactionFactItem:
			if tags:
				for tag in tags:
					tag.facts.erase(self.uid)
					
			for tag in value:
				tag.facts[self.uid] = true
				
		tags = value

@export_group("")

var parent_item: ReactionBaseItem

var sqlite_id: int

var sqlite_table_name: String = ""

var _sqlite_database: SQLite

var _ignore_fields = {
	"resource_local_to_scene": true,
	"resource_name": true,
	"script": true,
}

# var _current_sqlite_data: Dictionary = {}

func _init() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database

func _get_where():
	return "id = %s" % [sqlite_id]

func add_tag(tag: ReactionTagItem) -> void:
	tags.append(tag)
	
	
func remove_tag(tag_uid: String) -> void:
	var index = 0
	for tag in tags:
		if tag.uid == tag_uid:
			break
		
		index += 1
		
	tags.remove_at(index)
	
	
func add_to_sqlite():
	var data = get_sqlite_dict_from_field_values()
	
	if parent_item:
		data[parent_item.sqlite_table_name + "_id"] = parent_item.sqlite_id
	
	_sqlite_database.insert_row(sqlite_table_name, data)
	sqlite_id = _sqlite_database.last_insert_rowid
	# update_from_sqlite()
	
	return data
	
	
func remove_from_sqlite() -> bool:
	var where = _get_where()
	var success = _sqlite_database.delete_rows(sqlite_table_name, where)
	sqlite_id = _sqlite_database.last_insert_rowid
	
	return success
	
	
func update_sqlite():
	var data = get_sqlite_dict_from_field_values()
	var where = _get_where()
	_sqlite_database.update_rows(sqlite_table_name, where, data)
	# update_from_sqlite()
	
func get_sqlite_list(get_resources=false):
	var results
	if not parent_item:
		results = _sqlite_database.select_rows(sqlite_table_name, "", ["*"])
	else:
		var where = " %s_id = %d" % [parent_item.sqlite_table_name, parent_item.sqlite_id]
		results = _sqlite_database.select_rows(sqlite_table_name, where, ["*"])
		
	if get_resources:
		var resource_result = []
		for result in results:
			var current_resource = get_new_object()
			current_resource.set_field_values_from_sqlite_dict(result)
			resource_result.append(current_resource)
			
		return resource_result
	
	return results

func set_field_values_from_sqlite_dict(data: Dictionary) -> void:
	sqlite_id = data.get("id", null)
	
	for prop in self.get_property_list():
		if prop.has("usage") and (prop.usage & PROPERTY_USAGE_STORAGE) != 0:
			var name = prop.name
			var type = prop.type
			if not _ignore_fields.has(name):
				if data.has(name):
					match type:
						TYPE_NIL:
							set(name, str(data.get(name)))
						TYPE_INT:
							set(name, int(data.get(name)))
						TYPE_STRING:
							set(name, str(data.get(name)))
						TYPE_BOOL:
							set(name, !!data.get(name))
						TYPE_DICTIONARY:
							set(name, JSON.parse_string(data.get(name)))
						TYPE_OBJECT:
							var object = get(name)
							var resource = object.get_script()
							var resource_new = resource.new().get_new_object()
							resource_new.sqlite_id = data.get(name + "_id")
							resource_new.remove_from_sqlite()
							set(name, resource_new)
						_:
							continue
				
func update_from_sqlite():
	var where = _get_where()
	var result = _sqlite_database.select_rows(sqlite_table_name, where, ["*"])
	
	if len(result) > 0:
		result = result[0]
		set_field_values_from_sqlite_dict(result)
		
		
func get_tags():
	var where = "%s = %d" % [sqlite_table_name + "_id", sqlite_id]
	
	var related_relation_query_field_name = "%s.%s" % ["tag_item_rel", "tag_id"]
	var parent_relation_query_field_name = "%s.%s" % ["tag_item_rel", sqlite_table_name + "_id"]
		
	var query = """
	SELECT tag.id AS id, tag_item_rel.id AS rel_id, tag.label AS label, tag.uid AS uid FROM %s 
	INNER JOIN %s ON %s.id = %s
	WHERE %s = %d;
	""" % ["tag", "tag_item_rel", "tag", related_relation_query_field_name, parent_relation_query_field_name, sqlite_id]
	
	_sqlite_database.query(query)
	var result = _sqlite_database.query_result_by_reference
	
	return result
	
func _to_string():
	return label
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.BASE
	
	
func get_sqlite_dict_from_field_values() -> Dictionary:
	var result = {}
	
	if sqlite_id:
		result["id"] = sqlite_id
		
	for prop in self.get_property_list():
		if prop.has("usage") and (prop.usage & PROPERTY_USAGE_STORAGE) != 0:
			var name = prop.name
			var type = prop.type
			if not _ignore_fields.has(name):
				match type:
					TYPE_NIL:
						result[name] = str(get(name))
					TYPE_INT:
						result[name] = int(get(name))
					TYPE_STRING:
						result[name] = str(get(name))
					TYPE_BOOL:
						result[name] = 0 if not get(name) else 1
					TYPE_DICTIONARY:
						result[name] = JSON.stringify(get(name))
					TYPE_OBJECT:
							var object = get(name)
							result[name + "_id"] = object.sqlite_id
					_:
						continue
			
	return result
	
static func get_new_object():
	pass
