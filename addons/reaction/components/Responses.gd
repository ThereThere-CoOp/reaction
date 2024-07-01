@tool
class_name Responses
extends MarginContainer

var current_database: ReactionDatabase

var root_response_group: ReactionResponseGroupItem

@onready var response_group_edit_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/ResponseGroupEditForm.tscn")
@onready var dialog_response_edit_form_scene: PackedScene = preload("res://addons/reaction/components/responses_edit_forms/DialogResponseEditForm.tscn")

@onready var add_response_group_button: Button = %AddResponseGroupButton
@onready var add_response_menu_button: MenuButton = %AddResponseMenuButton
@onready var edit_response_button: Button = %EditResponseButton
@onready var remove_response_button: Button = %RemoveResponseButton

@onready var responses_tree: Tree = %ResponsesTree
@onready var edit_response_dialog: AcceptDialog = %EditResponsetDialog

var _dictionary_responses_data = {}


func _ready():
	call_deferred("apply_theme")
	ReactionSignals.database_selected.connect(_on_database_selected)
	
	var add_response_menu_popup: PopupMenu = add_response_menu_button.get_popup()
	add_response_menu_popup.clear()
	for response_type in ReactionGlobals.responses_types.values():
		add_response_menu_popup.add_item(response_type)
		
	add_response_menu_popup.index_pressed.connect(_on_add_response_menu_index_pressed)


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
	for response in response_group.responses.values():
		var child = _create_response_tree_item(parent_node, response)

		if response is ReactionResponseGroupItem:
			add_child_responses_to_tree(child, response)
		
		
func setup(response_group: ReactionResponseGroupItem) -> void:
	root_response_group = response_group
	
	remove_response_button.disabled = true
	
	responses_tree.clear()
	var root = responses_tree.create_item()
	root.set_metadata(0, root_response_group)
	responses_tree.hide_root = true
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
	add_response_group_button.disabled = false
	add_response_menu_button.disabled = false
	_get_selected_tree_item().deselect(0)
	
	
func _show_edit_dialog() -> void:
	var selected_response = _get_selected_response()
	print(selected_response.get_class())
	var response_type = ReactionGlobals.get_item_type(selected_response)
	edit_response_dialog.title = ("Edit %s" % response_type)
	var form_scene: MainResponseEditForm
	
	match response_type:
		"Response Group":
			form_scene = response_group_edit_form_scene.instantiate()
		"Dialog":
			form_scene = dialog_response_edit_form_scene.instantiate()
		_:
			form_scene = response_group_edit_form_scene.instantiate()
	
	for child in edit_response_dialog.get_children():
		child.queue_free()
	
	form_scene.setup(current_database, selected_response, _get_selected_tree_item())
	edit_response_dialog.add_child(form_scene)
	edit_response_dialog.popup_centered()
		
		
### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


func _on_database_selected(database: ReactionDatabase) -> void:
	current_database = database


func _on_responses_tree_item_selected():
	var response : ReactionResponseBaseItem = _get_selected_response()
	
	remove_response_button.disabled = false
	add_response_group_button.disabled = bool(not response is ReactionResponseGroupItem)
	add_response_menu_button.disabled = bool(not response is ReactionResponseGroupItem)
		
			
func _on_responses_tree_nothing_selected():
	_deselect_item()


func _on_add_response_group_button_pressed():
	var selected_item : TreeItem = _get_selected_tree_item()
	var response: ReactionResponseBaseItem = _get_selected_response()
	
	var new_response_group: ReactionResponseGroupItem = response.add_new_response_group()
	current_database.save_data()
	
	_create_response_tree_item(selected_item, new_response_group)
	
	
func _on_add_response_menu_index_pressed(index):
	var popup = add_response_menu_button.get_popup()
	var label = popup.get_item_text(index)
	
	var selected_item : TreeItem = _get_selected_tree_item()
	var response: ReactionResponseBaseItem = _get_selected_response()
	
	var new_response: ReactionResponseItem = response.add_new_response(label)
	current_database.save_data()
	
	_create_response_tree_item(selected_item, new_response)


func _on_remove_response_button_pressed():
	if responses_tree.get_selected():
		var selected_item : TreeItem = _get_selected_tree_item()
		var response: ReactionResponseBaseItem = _get_selected_response()
		current_database.save_data()
		
		var parent: TreeItem = selected_item.get_parent()
		var parent_response: ReactionResponseGroupItem = parent.get_metadata(0)
		parent_response.remove_response(response.uid)
		_deselect_item()
		parent.remove_child(selected_item)


func _on_edit_response_button_pressed():
	_show_edit_dialog()


func _on_responses_tree_item_activated():
	_show_edit_dialog()
