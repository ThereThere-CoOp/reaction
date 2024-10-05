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
	item_object.fact = item
	current_database.save_data()
