@tool
extends HBoxContainer

signal item_selected(item: Resource)

@export var popup_wait_time: float = 5.0

@export var items_list : Array = []

@export var field_search_name: String  = "label"

var current_list : Array[Resource] = []

var current_item : Resource = null

@onready var search_input: LineEdit = %SearchLineEdit
@onready var popup_menu: PopupMenu = %PopupMenu
@onready var popup_timer: Timer = %PopupTimer

var _current_search_text: String

func _ready():
	popup_timer.wait_time = popup_wait_time


func _get_new_list(word: String) -> Array[Resource]:
	var result : Array[Resource] = []
	for item in items_list:
		if item.get(field_search_name).contains(word):
			result.append(item)
			
	return result
		
		
### signals


func _on_search_line_edit_text_changed(new_text):
	popup_timer.start()
	_current_search_text = new_text
		

func _on_popup_menu_index_pressed(index):
	search_input.text = current_list[index].get(field_search_name)
	current_item = current_list[index]
	item_selected.emit(current_item)


func _on_popup_timer_timeout() -> void:
	popup_menu.clear()
	current_list = _get_new_list(_current_search_text)
	if current_list.size() > 0:
		for item in current_list:
			popup_menu.add_item(item.get(field_search_name))
		
		popup_menu.popup(Rect2i(global_position.x, global_position.y + 100 , size.x, 150))
