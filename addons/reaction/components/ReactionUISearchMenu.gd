@tool
class_name ReactionUISearchMenu
extends HBoxContainer

signal item_selected(item)

signal item_removed(item)

@export var search_input_text: String = ""

@export var popup_wait_time: float = 5.0

@export var items_list = []

@export var field_search_name: String  = "label"

var current_list = []

var current_item: Resource = null

@onready var search_input: LineEdit = %SearchLineEdit
@onready var popup_menu: PopupMenu = %PopupMenu
@onready var clean_button: Button = %CleanButton
@onready var popup_timer: Timer = %PopupTimer

var _current_search_text: String

func _ready():
	search_input = %SearchLineEdit
	popup_timer.wait_time = popup_wait_time
	
	if search_input:
		search_input.text = search_input_text
	
	if Engine.is_editor_hint():
		call_deferred("apply_theme")
		
		
func clean():
	item_removed.emit(current_item)
	current_item = null
	update_search_text_value("")
	
	
func apply_theme() -> void:
	# Simple check if onready
	clean_button.icon = get_theme_icon("Clear", "EditorIcons")
		
	
	
func update_search_text_value(value: String) -> void:
	search_input_text = value
	
	if not search_input:
		search_input = %SearchLineEdit
		
	search_input.text = search_input_text


func _get_new_list(word: String):
	var result = []
	for item in items_list:
		if item.get(field_search_name).contains(word):
			result.append(item)
			
	return result
		
		
### signals


func _on_main_view_theme_changed() -> void:
	apply_theme()


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
		
		popup_menu.popup_on_parent(Rect2i(global_position.x, global_position.y + search_input.size.y , size.x, 150))


func _on_clean_button_pressed() -> void:
	clean()
