@tool
class_name ResponseGroup
extends MarginContainer

@export var responses_types: PackedStringArray = ["Dialog Response"]

@onready var add_response_menu : MenuButton = %AddResponsesMenuButton
@onready var show_hide_responses_button : CheckButton = %ShowHideResponsesButton
@onready var responses_container : VBoxContainer = %ResponsesContainer
@onready var responses_scroll_container : ScrollContainer = %ResponsesScrollContainer
@onready var _responses_scrollbar: VScrollBar = responses_scroll_container.get_v_scroll_bar()

var _responses_scroll_to_end = false

func _ready():
	_responses_scrollbar.changed.connect(_on_responses_scroll_changed)
	
	var responses_menu_popup = add_response_menu.get_popup()
	responses_menu_popup.clear()
	for response_type in responses_types:
		responses_menu_popup.add_item(response_type)


func _on_responses_scroll_changed() -> void:
	if _responses_scroll_to_end:
		responses_scroll_container.set_v_scroll(int(_responses_scrollbar.max_value))
		

func _on_show_hide_responses_button_toggled(toggled_on):
	responses_scroll_container.visible = toggled_on
