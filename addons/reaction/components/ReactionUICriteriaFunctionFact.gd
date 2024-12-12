@tool
class_name ReactionUICriteriaFunctionFact
extends ReactionUIListObjectFormItem


var fact_search_menu: ReactionUISearchMenu


func setup(database: ReactionDatabase, parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:
	super(database, parent_object, object, index, is_new_object)
	
	fact_search_menu = %FactSearchMenu
	
	fact_search_menu.items_list = database.global_facts.values()
	
	if item_object.fact:
		fact_search_menu.search_input_text = item_object.fact.label
	
	
### signals

func _on_fact_input_item_selected(item: Resource) -> void:
	
	if item_object.fact:
		current_database.remove_fact_reference_log(item_object)
	
	item_object.fact = item
	
	var new_item_log: ReactionReferenceLogItem = ReactionReferenceLogItem.new()
	new_item_log.update_log_objects(item_object, current_database)
	current_database.add_fact_reference_log(new_item_log)
	current_database.save_data()
