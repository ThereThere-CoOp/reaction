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
@export var return_method = ""

## dictionary to store response settings each key is the response uid
## and the values is a dict with the settings
## ordered by the execution order value
@export var responses_settings = {}

## dictionary to store the current executed responses
## each key is an response uid
@export var executed_responses = {}

## current index to cycle through when return method is by exection order
@export var order_current_index = 0


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
	

func _get_not_executed_responses(current_responses: Dictionary, executed_dict: Dictionary) -> Dictionary:
	var result = {}
	for response_uid in current_responses.keys():
		if not executed_dict.has(response_uid):
			result[response_uid] = responses[response_uid]
			
	return result
	
	
func _get_children_response_change_execution_stats(current_response: ReactionResponseBaseItem, context: ReactionBlackboard) -> ReactionResponseBaseItem:
	if current_response == null:
		return null
	
	var responses_size = responses.size()
	if responses_settings.get(current_response.uid, {}).get("return_once", false):
		executed_responses[current_response.uid] = true
		
		if return_method == ReactionGlobals.EXECUTION_ORDER_RETURN_METHOD:
			responses_size = responses.size() - executed_responses.size()
			if responses_size > 0:
				order_current_index %= responses_size
			else:
				order_current_index = 0
	else:
		if return_method == ReactionGlobals.EXECUTION_ORDER_RETURN_METHOD:
			responses_size = responses.size() - executed_responses.size()
			order_current_index = (order_current_index + 1) % responses_size

	if current_response is ReactionResponseGroupItem:
		return current_response.get_response_by_method(context)
	else:
		return current_response
		
		
func return_response_by_random(context: ReactionBlackboard, randomizer: RandomNumberGenerator)  -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses(responses, executed_responses)
	
	if no_executed_responses.size() == 0:
		return null
		
	if randomizer == null:
		randomizer = RandomNumberGenerator.new()
		randomizer.randomize()
	
	var responses_values = no_executed_responses.values()
	var random = randomizer.randi_range(0, responses_values.size() - 1)
	var current_response: ReactionResponseBaseItem = responses_values[random]
	
	return _get_children_response_change_execution_stats(current_response, context)
		
		
func return_response_by_execution_order(context: ReactionBlackboard) -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses(responses, executed_responses)
	
	if no_executed_responses.size() == 0:
		return null
		
	var sorted_responses_values = no_executed_responses.values()
	
	sorted_responses_values.sort_custom(func(a, b): 
		return responses_settings.get(a.uid, {}).get("execution_order", 0) < responses_settings.get(b.uid, {}).get("execution_order", 0)
	)
	
	return _get_children_response_change_execution_stats(sorted_responses_values[order_current_index], context)
	
	
func return_response_by_random_weight(context: ReactionBlackboard, randomizer: RandomNumberGenerator) -> ReactionResponseBaseItem:
	var no_executed_responses = _get_not_executed_responses(responses, executed_responses)
	
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
	
	if randomizer == null:
		randomizer = RandomNumberGenerator.new()
		randomizer.randomize()
		
	var rnd = randomizer.randf() * total
	var cumulative: float = 0.0
	var current_response = null
	for i in range(responses_values.size()):
		cumulative += weights[i]
		if rnd <= cumulative:
			current_response = responses_values[i]
	
	return _get_children_response_change_execution_stats(current_response, context)


func get_response_by_method(context: ReactionBlackboard, randomizer: RandomNumberGenerator=null) -> ReactionResponseBaseItem:
	if return_method == ReactionGlobals.RANDOM_RETURN_METHOD:
		return return_response_by_random(context, randomizer)
	elif return_method == ReactionGlobals.EXECUTION_ORDER_RETURN_METHOD:
		return return_response_by_execution_order(context)
	elif return_method == ReactionGlobals.RANDOM_WEIGHT_RETURN_METHOD:
		return return_response_by_random_weight(context, randomizer)
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
	group_by_placeholders = ["execution_order ASC"] if self.return_method == ReactionGlobals.EXECUTION_ORDER_RETURN_METHOD else ["reaction_item_type ASC"]
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
	
	var children_responses_dict = get_sqlite_children_list(null, false)
	
	for index in range(children_responses.size()):
		var response = children_responses[index]
		var response_setting = children_responses_dict[index]
		
		response.export()
		responses[response.uid] = response
		
		responses_settings[response_setting.get("uid", "nop")] = response_setting		
		
	
static func get_new_object():
	return ReactionResponseGroupItem.new()
		
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP
