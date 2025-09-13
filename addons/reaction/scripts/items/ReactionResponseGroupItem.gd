@tool
class_name ReactionResponseGroupItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a response group.
##
## A response group have at least one response a [ReactionResponseItem] and
## manage the behavior of the responses within it.
## ----------------------------------------------------------------------------


## dict of responses or responses groups
@export var responses = {}

## the method how the group will return the response
## by_order: By response order
## random: Randomly each time
## random_weight: By random using a weight from a function
@export var return_method = "random"

## dictionary to store response settings each key is the response uid
## and the values is a dict with the settings
@export var responses_settings = {}

## dictionary to store the current executed responses
## each key is an response uid
@export var executed_responses = {}

func _init() -> void:
	super()
	label = "newResponseGroup"
	sqlite_table_name = "response_group"
	_ignore_fields.merge(
		{ "responses": true }
	)
	
	
func remove_response(response_uid: String) -> void:
	responses.erase(response_uid)
	
	
func get_responses() -> Array[ReactionResponseBaseItem]:
	var result: Array[ReactionResponseBaseItem]
	result.assign(responses.values())
	return result
	

func add_sqlite_response_group(response_group: ReactionResponseGroupItem) -> void:
	_sqlite_database.insert_row("response_parent_group_rel", {
		"parent_group_id": sqlite_id,
		"response_group_id": response_group.sqlite_id
	})
	
	
func add_sqlite_response(response: ReactionResponseItem) -> void:
	_sqlite_database.insert_row("response_parent_group_rel", {
		"parent_group_id": sqlite_id,
		"response_id": response.sqlite_id
	})
	
	
func get_sqlite_children_list(custom_where=null, get_resources=false):
	var where = ""
	if custom_where:
		where = " AND (%s)" % [custom_where]
		
	var groups_query = """
	SELECT response_group.id AS id, response_group.label AS label, response_group.uid AS uid, response_group.reaction_item_type AS reaction_item_type
	FROM response_group
	INNER JOIN response_parent_group_rel ON response_group.id = response_parent_group_rel.response_group_id
	WHERE response_parent_group_rel.parent_group_id = %d %s
	""" % [ sqlite_id, where ]
		
	var responses_query = """
	SELECT response.id AS id, response.label AS label, response.uid AS uid, response.reaction_item_type AS reaction_item_type
	FROM response
	INNER JOIN response_parent_group_rel ON response.id = response_parent_group_rel.response_id
	WHERE response_parent_group_rel.parent_group_id = %d %s
	""" % [ sqlite_id, where ]
	
	var query = """
	%s
	UNION
	%s
	""" % [groups_query, responses_query]
	
	_sqlite_database.query(query)
	var results = _sqlite_database.query_result
		
	if get_resources:
		var resource_result = []
		for result in results:
			var current_resource = ReactionGlobals.get_response_object_from_reaction_type(result.get("reaction_item_type"))
			current_resource.sqlite_id = result["id"]
			current_resource.update_from_sqlite()
			resource_result.append(current_resource)
			
		return resource_result
	else:
		return results
		
		
func export():
	var children_responses = get_sqlite_children_list(null, true)
	for response in children_responses:
		response.export()
		responses[response.uid] = response
		
	
static func get_new_object():
	return ReactionResponseGroupItem.new()
		
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP
