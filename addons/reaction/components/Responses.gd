@tool
class_name Responses
extends MarginContainer

var root_response_group: ReactionResponseGroupItem

@onready var response_group_edit_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/ReactionUIResponseGroupEditForm.tscn")

@export var responses_to_add_data_array: Array[ListObjectFormObjectToAdd] = []

@onready var add_response_group_button: Button = %AddResponseGroupButton
@onready var add_existing_response_button: Button = %AddExistingResponseButton
@onready var add_response_menu_button: MenuButton = %AddResponseMenuButton
@onready var edit_response_button: Button = %EditResponseButton
@onready var remove_response_button: Button = %RemoveResponseButton
@onready var responses_search_menu: ReactionUISearchMenu = %ResponsesSearchMenu

@onready var responses_tree: Tree = %ResponsesTree
@onready var add_exisiting_response_confirmation_dialog: ConfirmationDialog = %AddExistingResponseConfirmationDialog
@onready var edit_response_dialog: AcceptDialog = %EditResponsetDialog
@onready var delete_response_confirmation_dialog: ConfirmationDialog = %DeleteResponseConfirmationDialog

var _dictionary_responses_data = {}

var _sqlite_database: SQLite

func _ready():
	call_deferred("apply_theme")
	ReactionSignals.database_selected.connect(_on_database_selected)
	
	var add_response_menu_popup: PopupMenu = add_response_menu_button.get_popup()
	add_response_menu_popup.clear()
	for response_type in ReactionGlobals.responses_types.values():
		add_response_menu_popup.add_item(response_type)
		
	add_response_menu_popup.index_pressed.connect(_on_add_response_menu_index_pressed)
	
	delete_response_confirmation_dialog.add_button("Delete only relation", true, "remove_relation")


func _create_response_tree_item(parent_node: TreeItem, response: ReactionResponseBaseItem) -> TreeItem:
	var child = responses_tree.create_item(parent_node)
	child.set_metadata(0, response)
	child.set_text(0, response.label)

	if response is ReactionResponseGroupItem:
		child.set_icon(0, get_theme_icon("Grid", "EditorIcons"))
	else:
		child.set_icon(0, get_theme_icon("GraphNode", "EditorIcons"))
		
	return child
	
	
func apply_theme() -> void:
	# Simple check if onready
	if is_instance_valid(edit_response_button):
		edit_response_button.icon = get_theme_icon("Edit", "EditorIcons")
		remove_response_button.icon = get_theme_icon("Remove", "EditorIcons")
		
		
func add_child_responses_to_tree(parent_node: TreeItem, response_group: ReactionResponseGroupItem) -> void:
	for response in response_group.get_sqlite_children_list(null, true):
		var child = _create_response_tree_item(parent_node, response)

		if response is ReactionResponseGroupItem:
			add_child_responses_to_tree(child, response)
		
		
func setup(response_group: ReactionResponseGroupItem) -> void:
	root_response_group = response_group
	
	var responses_menu: PopupMenu = add_response_menu_button.get_popup()
	responses_menu.clear()
	
	for add_response: ListObjectFormObjectToAdd in responses_to_add_data_array:
		responses_menu.add_item(add_response.object_name)
	
	add_response_group_button.disabled = true
	add_existing_response_button.disabled = true
	add_response_menu_button.disabled = true
	remove_response_button.disabled = true
	
	var response_resource: ReactionResponseItem = ReactionResponseItem.get_new_object()
	var responses_list = response_resource.get_sqlite_list(null, true)
	responses_search_menu.items_list = responses_list
	
	# setup responses tree
	responses_tree.clear()
	var root = responses_tree.create_item()
	root.set_metadata(0, root_response_group)
	root.set_text(0, root_response_group.label)
	root.set_icon(0, get_theme_icon("Grid", "EditorIcons"))
	add_child_responses_to_tree(root, root_response_group)
	
	
func _get_selected_tree_item() -> TreeItem:
	var selected_item : TreeItem = responses_tree.get_selected()
	
	if selected_item:
		return selected_item
	else:
		return responses_tree.get_root()
	
	
func _get_selected_response() -> ReactionResponseBaseItem:
	var selected_item : TreeItem = responses_tree.get_selected()
	var response: ReactionResponseBaseItem
	
	if selected_item:
		return selected_item.get_metadata(0)
	else:
		return root_response_group
		
		
func _deselect_item() -> void:
	remove_response_button.disabled = true
	add_response_group_button.disabled = true
	add_existing_response_button.disabled = true
	add_response_menu_button.disabled = true
	_get_selected_tree_item().deselect(0)
		
		
func _get_response_from_add_data_array(response_type: int) -> ListObjectFormObjectToAdd:
	for add_response in responses_to_add_data_array:
		var tmp_object: ReactionResponseItem = add_response.object_resource_class.get_new_object()
		if tmp_object.reaction_item_type == response_type:
			return add_response
			
	return null
	
	
func _show_edit_dialog() -> void:
	var selected_response = _get_selected_response()
	var response_type = selected_response.reaction_item_type
	edit_response_dialog.title = ("Edit %s" % response_type)
	var form_scene: ReactionUIMainResponseEditForm
	
	if response_type == ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP:
		form_scene = response_group_edit_form_scene.instantiate()
	else:
		form_scene = _get_response_from_add_data_array(response_type).form_scene.instantiate()
	
	for child in edit_response_dialog.get_children():
		child.queue_free()
	
	form_scene.setup(selected_response)
	edit_response_dialog.add_child(form_scene)
	form_scene.field_updated.connect(_on_response_label_updated)
	edit_response_dialog.popup_centered()
		
		
func _remove_response_response_group_relation():
	if responses_tree.get_selected():
		var selected_item : TreeItem = _get_selected_tree_item()
		var response: ReactionResponseBaseItem = _get_selected_response()
		
		var parent: TreeItem = selected_item.get_parent()
		var parent_response: ReactionResponseGroupItem = parent.get_metadata(0)
		
		var where = "parent_group_id = %d AND response_id = %d" % [parent_response.sqlite_id, response.sqlite_id]
		_sqlite_database.delete_rows("response_parent_group_rel", where)
		
		_deselect_item()
		parent.remove_child(selected_item)
		
	delete_response_confirmation_dialog.hide()
		
		
### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_database_selected() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database


func _on_responses_tree_item_selected():
	var response : ReactionResponseBaseItem = _get_selected_response()
	var item_selected = _get_selected_tree_item()
	
	if item_selected.get_parent() != null:
		remove_response_button.disabled = false
	else:
		remove_response_button.disabled = true
	
	add_existing_response_button.disabled = bool(not response is ReactionResponseGroupItem)
	add_response_group_button.disabled = bool(not response is ReactionResponseGroupItem)
	add_response_menu_button.disabled = bool(not response is ReactionResponseGroupItem)
		

func _on_responses_tree_nothing_selected():
	_deselect_item()


func _on_add_response_group_button_pressed():
	var selected_item : TreeItem = _get_selected_tree_item()
	var response: ReactionResponseBaseItem = _get_selected_response()
	
	var new_response_group: ReactionResponseGroupItem = ReactionResponseGroupItem.get_new_object()
	new_response_group.add_to_sqlite()
	response.add_sqlite_response_group(new_response_group)
	
	_create_response_tree_item(selected_item, new_response_group)
	
	
func _on_add_response_menu_index_pressed(index):
	var popup = add_response_menu_button.get_popup()
	var label = popup.get_item_text(index)
	
	var selected_item : TreeItem = _get_selected_tree_item()
	var response: ReactionResponseBaseItem = _get_selected_response()
	
	var new_response: ReactionResponseItem = responses_to_add_data_array[index].object_resource_class.get_new_object()
	new_response.add_to_sqlite()
	response.add_sqlite_response(new_response)
	
	_create_response_tree_item(selected_item, new_response)


func _on_remove_response_button_pressed():
	if responses_tree.get_selected():
		var selected_item : TreeItem = _get_selected_tree_item()
		var response: ReactionResponseBaseItem = _get_selected_response()
		
		if response.reaction_item_type == ReactionGlobals.ItemsTypesEnum.RESPONSE_GROUP:
			response.remove_from_sqlite()
			var parent: TreeItem = selected_item.get_parent()
			_deselect_item()
			parent.remove_child(selected_item)
		else:
			delete_response_confirmation_dialog.popup_centered()


func _on_edit_response_button_pressed():
	_show_edit_dialog()


func _on_responses_tree_item_activated():
	_show_edit_dialog()


func _on_delete_response_confirmation_dialog_confirmed() -> void:
	if responses_tree.get_selected():
		var selected_item : TreeItem = _get_selected_tree_item()
		var response: ReactionResponseBaseItem = _get_selected_response()
		
		response.remove_from_sqlite()
		var parent: TreeItem = selected_item.get_parent()
		_deselect_item()
		parent.remove_child(selected_item)


func _on_delete_response_confirmation_dialog_custom_action(action: StringName) -> void:
	match action:
		"remove_relation":
			_remove_response_response_group_relation()
		
		
func _on_add_existing_response_button_pressed() -> void:
	add_exisiting_response_confirmation_dialog.popup_centered()


func _on_add_existing_response_confirmation_dialog_confirmed() -> void:
	var popup = add_response_menu_button.get_popup()
	
	var selected_item : TreeItem = _get_selected_tree_item()
	var response: ReactionResponseBaseItem = _get_selected_response()
	
	var new_response = responses_search_menu.current_item
	if new_response:
		var current_resource = ReactionGlobals.get_response_object_from_reaction_type(new_response.get("reaction_item_type"))
		current_resource.sqlite_id = new_response.sqlite_id
		current_resource.update_from_sqlite()
		
		response.add_sqlite_response(current_resource)
		_create_response_tree_item(selected_item, current_resource)
		
	responses_search_menu.clean()


func _on_add_existing_response_confirmation_dialog_canceled() -> void:
	responses_search_menu.clean()
	
func _on_response_label_updated(field_name: String, value: Variant):
	if field_name == "label":
		var selected_item : TreeItem = _get_selected_tree_item()
		selected_item.set_text(0, value)
