@tool
extends HBoxContainer

signal item_selected(item: Resource)

@export var items_list : Array = []

var current_list : Array[Resource] = []

var current_item : Resource = null

@export var field_search_name: String  = "label"

@onready var search_input: LineEdit = %SearchLineEdit
@onready var popup_menu: PopupMenu = %PopupMenu


func _ready():
	popup_menu.position = Vector2(position.x, position.y + size.y)


func _get_new_list(word: String) -> Array[Resource]:
	var result : Array[Resource] = []
	for item in items_list:
		if item.get(field_search_name).contains(word):
			result.append(item)
			
	return result
		
		
### signals


func _on_search_line_edit_text_changed(new_text):
	current_list = _get_new_list(new_text)
	if current_list.size() > 0:
		for item in current_list:
			popup_menu.add_item(item.get(field_search_name))
			
		popup_menu.visible = true


func _on_popup_menu_index_pressed(index):
	search_input.text = current_list[index].get(field_search_name)
	current_item = current_list[index]
	popup_menu.visible = false
	item_selected.emit(current_item)
