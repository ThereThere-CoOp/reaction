@tool
class_name ReactionResponseGroupItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a response group.
##
## A response group have at least one response a [ReactionResponseItem] and
## manage the behavior of the responses within it.
## ----------------------------------------------------------------------------


var EXECUTION_ORDER_RETURN_METHOD = ReactionGlobals.EXECUTION_ORDER_RETURN_METHOD
var RANDOM_RETURN_METHOD = ReactionGlobals.RANDOM_RETURN_METHOD
var RANDOM_WEIGHT_RETURN_METHOD = ReactionGlobals.RANDOM_WEIGHT_RETURN_METHOD


## dict of responses or responses groups
@export var responses = {}

## the method how the group will return the response
## by_order: By response order
## random: Randomly each time
## random_weight: By random using a weight from a function
@export var return_method = RANDOM_RETURN_METHOD

## dictionary to store response settings each key is the response uid
## and the values is a dict with the settings
## ordered by the execution order value
@export var responses_settings = {}

## dictionary to store the current executed responses
## each key is an response uid
@export var executed_responses = {}

## uid of the last response to be executed
@export var last_executed_response: String

func _init() -> void:
	super()
	label = "newResponseGroup"
	sqlite_table_name = "response_group"
	_ignore_fields.merge(
		{ 
			"responses": true,
			"responses_settings": true,
			"executed_responses": true,
		}
	)
	
	
func remove_response(response_uid: String) -> void:
	responses.erase(response_uid)
	
	
func get_responses() -> Array[ReactionResponseBaseItem]:
	var result: Array[ReactionResponseBaseItem]
	result.assign(responses.values())
	return result
	

func _get_not_executed_responses() -> Dictionary:
	var result = {}
	for response_uid in responses.keys():
		if not executed_responses.has(response_uid):
			result[response_uid] = responses[response_uid]
			
	return result
	
	
func _get_children_response_change_execution_stats(current_response: ReactionResponseBaseItem) -> ReactionResponseBaseItem:
	if current_response == null:
		return current_response
		
	if responses_settings[current_response.uid].get("return_once", false):
		executed_responses[current_response.uid] = true
	
	last_executed_response = current_response.uid
	
	if current_response is ReactionResponseGroupItem:
		return current_response.get_response_by_method()
	else:
		return current_response
		
		
func return_response_by_random()  -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses()
	
	if no_executed_responses.size() == 0:
		return null
	
	var responses_values = no_executed_responses.values()
	var random = randi_range(0, responses_values.size())
	var current_response: ReactionResponseBaseItem = responses_values[random]
	
	return _get_children_response_change_execution_stats(current_response)
		
		
func return_response_by_execution_order() -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses()
	
	if no_executed_responses.size() == 0:
		return null
		
	var sorted_responses_values = no_executed_responses.values()
	
	sorted_responses_values.sort_custom(func(a, b): 
		return responses_settings[a.uid].get("execution_order", 0) < responses_settings[a.uid].get("execution_order", 0)
	)
	
	if last_executed_response != null or last_executed_response != "":
		var last_executed_value = null
		for value in sorted_responses_values:
			if sorted_responses_values.uid == last_executed_response:
				last_executed_value = value
				sorted_responses_values.erase(value)
	
	return _get_children_response_change_execution_stats(sorted_responses_values[0])
	
	
func return_response_by_random_weight(context: ReactionBlackboard) -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses()
	
	if no_executed_responses.size() == 0:
		return null
		
	var responses_values = no_executed_responses.values()
	
	var weights: Array = []
	var total: float = 0.0
	
	for response in responses_values:
		var w = ReactionGlobals.get_function_result(responses_settings[response.uid].get("weight_function", "0.0"), context)
		weights.append(w)
		total += w

	if total <= 0.0:
		return null  # no valid weights

	# Normalize weights
	for i in range(weights.size()):
		weights[i] /= total

	# Pick by cumulative probability
	var rnd = randf()
	var cumulative: float = 0.0
	var current_response = null
	for i in range(responses_values.size()):
		cumulative += weights[i]
		if rnd <= cumulative:
			current_response = responses_values[i]
	
	return _get_children_response_change_execution_stats(current_response)


func get_response_by_method(context: ReactionBlackboard) -> ReactionResponseBaseItem:
	if return_method == RANDOM_RETURN_METHOD:
		return return_response_by_random()
	elif return_method == EXECUTION_ORDER_RETURN_METHOD:
		return return_response_by_execution_order()
	elif return_method == RANDOM_WEIGHT_RETURN_METHOD:
		return return_response_by_random_weight(context: ReactionBlackboard)
	return null


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
	SELECT response_group.id AS id, 
	response_group.label AS label, 
	response_group.uid AS uid, 
	response_group.reaction_item_type AS reaction_item_type,
	relation.id AS relation_id,
	relation.return_once AS return_once,
	relation.execution_order AS execution_order,
	relation.weight_function AS weight_function
	FROM response_group
	INNER JOIN response_parent_group_rel as relation
	ON response_group.id = relation.response_group_id
	WHERE relation.parent_group_id = %d %s
	""" % [ sqlite_id, where ]
		
	var responses_query = """
	SELECT response.id AS id, 
	response.label AS label, 
	response.uid AS uid, 
	response.reaction_item_type AS reaction_item_type,
	relation.id AS relation_id,
	relation.return_once AS return_once,
	relation.execution_order AS execution_order,
	relation.weight_function AS weight_function
	FROM response
	INNER JOIN response_parent_group_rel as relation 
	ON response.id = relation.response_id
	WHERE relation.parent_group_id = %d %s
	""" % [ sqlite_id, where ]
	
	var group_by_placeholders = []
	group_by_placeholders = ["execution_order ASC"] if self.return_method == EXECUTION_ORDER_RETURN_METHOD else ["reaction_item_type ASC"]
	var group_by = "ORDER BY %s" % group_by_placeholders
	
	
	# if self.return_method
	var query = """
	%s
	UNION
	%s
	%s
	""" % [groups_query, responses_query, group_by]
	
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
