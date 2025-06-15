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

@export var tags: Array[ReactionTag]: 
	set(value):
		if self is ReactionFactItem:
			if tags:
				for tag in tags:
					tag.facts.erase(self.uid)
					
			for tag in value:
				tag.facts[self.uid] = true
				
		tags = value

@export_group("")

var sqlite_id: int

var sqlite_table_name: String = ""

var _sqlite_database: SQLite

var _ignore_fields = {
	"resource_local_to_scene": true,
	"resource_name": true,
}

# var _current_sqlite_data: Dictionary = {}

func _init() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database

func add_tag(tag: ReactionTag) -> void:
	tags.append(tag)
	
	
func remove_tag(tag_uid: String) -> void:
	var index = 0
	for tag in tags:
		if tag.uid == tag_uid:
			break
		
		index += 1
		
	tags.remove_at(index)
	
	
func add_to_sqlite():
	print(get_sqlite_dict_from_field_values())
	var data = get_sqlite_dict_from_field_values()
	_sqlite_database.insert_row(sqlite_table_name, data)
	sqlite_id = _sqlite_database.last_insert_rowid
	update_from_sqlite()
	
	return get_sqlite_dict_from_field_values()
	
	
func update_sqlite():
	var data = get_sqlite_dict_from_field_values()
	var where = "id = %s" % [sqlite_id]
	_sqlite_database.update_rows(sqlite_table_name, where, data)
	update_from_sqlite()
	

func _set_field_values_from_sqlite_dict(data: Dictionary) -> void:
	label = data.get("label", "")
	uid = data.get("uid", "")
	description = data.get("description", "")
	scope = data.get("scope", "Global")
	
func update_from_sqlite():
	var where = "id = %s" % [sqlite_id]
	var result = _sqlite_database.select_rows(sqlite_table_name, where, ["*"])
	
	if len(result) > 0:
		result = result[0]
		_set_field_values_from_sqlite_dict(result)
	
	
func _to_string():
	return label
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.BASE
	
	
func get_sqlite_dict_from_field_values() -> Dictionary:
	var result = {}
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
					_:
						continue
			
	return result
