@tool
class_name Tags
extends MarginContainer

var current_database: ReactionDatabase

var current_tag: ReactionTag

@onready var tags_list: ReactionItemList = %TagList

@onready var tag_data_container : VBoxContainer = %TagDataContainer
@onready var tag_label_line_edit : LineEdit = %TagLabelLineEdit
@onready var tag_uid_line_edit : LineEdit = %TagUidLineEdit
@onready var tag_description_text_edit : TextEdit = %TagDescriptionTextEdit


func _ready() -> void:
	tag_data_container.visible = false
	
	ReactionSignals.database_selected.connect(setup_tags)


func setup_tags(database: ReactionDatabase) -> void:
	current_database = database
	tags_list.setup_items(current_database)


func _set_tag(tag_data: ReactionTag) -> void:
	current_tag = tag_data
	# set input default values
	tag_uid_line_edit.text = current_tag.uid
	tag_label_line_edit.text = current_tag.label
	tag_description_text_edit.text = current_tag.description
		
	tag_data_container.visible = true


func _set_tag_property(property_name: StringName, value: Variant) -> void:
	current_tag.set(property_name, value)
	current_database.save_data()


### signals


func _on_tag_label_line_edit_text_submitted(new_text):
	_set_tag_property("label", new_text)
	tags_list.items_list.set_item_text(tags_list.current_item_index, new_text)


func _on_tag_description_text_edit_text_changed():
	_set_tag_property("description", tag_description_text_edit.text)


func _on_tag_list_item_selected(item_data):
	_set_tag(item_data)
	

func _on_tags_list_item_added(index, item_data):
	_set_tag(item_data)


func _on_tags_list_item_removed(index, item_data):
	if current_database.tags.size() > 0:
		_set_tag(tags_list.current_item)
	else:
		tag_data_container.visible = false


func _on_tag_list_item_list_updated():
	tag_data_container.visible = false
