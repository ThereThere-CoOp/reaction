@tool
extends Node


func _get_items_tagged_by_tag(tag, item_table_name="fact"):
	var sqlite_database: SQLite = ReactionGlobals.current_sqlite_database
	
	var query = """
	SELECT %s.uid A
	FROM tag_item_rel
	INNER JOIN %s ON %s.id = tag_item_rel.%s_id
	WHERE tag_id = %d
	""" % [item_table_name, item_table_name, item_table_name, item_table_name, tag.sqlite_id]
	
	sqlite_database.query(query)
	
	return sqlite_database.query_result


func get_resource_from_database() -> ReactionDatabase:
	var result_resource_database: ReactionDatabase = ReactionDatabase.new()
	result_resource_database.label = 'exported_database'
	var sqlite_database: SQLite = ReactionGlobals.current_sqlite_database
	
	var global_facts_list = ReactionFactItem.new().get_sqlite_list(null, true)
	var global_facts_dict: Dictionary = {}
	
	for fact in global_facts_list:
		global_facts_dict[fact.uid] = fact
		
	result_resource_database.global_facts = global_facts_dict
	
	
	var tags_list: Array[ReactionTagItem] = ReactionTagItem.new().get_sqlite_list(null, true)
	var tags_dict: Dictionary = {}
	
	for tag in tags_list:
		var tag_facts_uids = _get_items_tagged_by_tag(tag, "fact")
		var tag_fact_dict = {}
		
		for fact_data in tag_facts_uids:
			tag_fact_dict[fact_data.get("uid")] = true
			
		tag.facts = tag_fact_dict
		tags_dict[tag.uid] = tag
			
	result_resource_database.tags = tags_dict
	
	return result_resource_database
