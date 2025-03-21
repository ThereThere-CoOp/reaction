@tool
class_name ReactionUICriteriaFunctionOperation
extends ReactionUIListObjectFormItem


var fact_search_menu: ReactionUISearchMenu

var operation_menu_button: MenuButton 

var operation_container: VBoxContainer 

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_operation_container_visibility()
		

func update_operation_container_visibility():
	if operation_container:
		if self.object_index == 0:
			operation_container.visible = false
		else:
			operation_container.visible = true


func setup(database: ReactionDatabase, parent_object: Resource, object: Resource, index: int, is_new_object: bool = false) -> void:
	super(database, parent_object, object, index, is_new_object)
	
	fact_search_menu = %FactSearchMenu
	operation_menu_button = %OperationMenuButton
	operation_container = %OperationContainer
	
	var operation_popup_menu: PopupMenu = operation_menu_button.get_popup()
	
	operation_popup_menu.index_pressed.connect(_on_operation_menu_index_pressed)
	
	fact_search_menu.items_list = database.global_facts.values()
	
	if item_object.fact:
		fact_search_menu.search_input_text = item_object.fact.label
		
	if item_object.operation:
		operation_menu_button.text = item_object.operation
	else:
		operation_menu_button.text = "Select operation"
		
	fact_search_menu.item_selected.connect(_on_fact_input_item_selected)
	
	
### signals

func _on_fact_input_item_selected(item: Resource) -> void:
	
	if item_object.fact:
		current_database.remove_fact_reference_log(item_object)
	
	item_object.fact = item
	
	var new_item_log: ReactionReferenceLogItem = ReactionReferenceLogItem.new()
	new_item_log.update_log_objects(item_object, current_database)
	current_database.add_fact_reference_log(new_item_log)
	current_database.save_data()
	
	
func _on_operation_menu_index_pressed(index: int) -> void:
	var popup = operation_menu_button.get_popup()
	var label = popup.get_item_text(index)
	
	item_object.operation = label
	operation_menu_button.text = label
	current_database.save_data()
