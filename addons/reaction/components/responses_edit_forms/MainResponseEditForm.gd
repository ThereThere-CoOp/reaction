@tool
class_name MainResponseEditForm
extends PanelContainer

var current_database: ReactionDatabase

var current_response: ReactionResponseBaseItem
var current_tree_item: TreeItem


@onready var label_input_line_edit: LineEdit = %LabelInputLineEdit
@onready var uid_line_edit: LineEdit = %UidLineEdit


func _ready():
	label_input_line_edit.text = current_response.label
	uid_line_edit.text = current_response.uid
	
	
func setup(database: ReactionDatabase, response: ReactionResponseBaseItem, tree_item: TreeItem) -> void:
	current_database = database
	current_response = response
	current_tree_item = tree_item


###  signals


func _on_label_input_line_edit_text_submitted(new_text):
	if new_text != "":
		current_response.label = new_text
		current_tree_item.set_text(0, new_text)
		current_database.save_data()
	
