@tool
extends ConfirmationDialog

signal database_updated(data: ReactionDatabase)

var data: ReactionDatabase = null

@onready var label_edit: LineEdit = %DatabaseNameLineEdit


func _ready() -> void:
	register_text_enter(label_edit)


func edit_database(database_data: ReactionDatabase) -> void:
	label_edit.text = database_data.label
	data = 	DeepClone.deep_clone(database_data)
	popup_centered()
	label_edit.grab_focus()
	label_edit.select_all()


### Signals


func _on_edit_board_dialog_confirmed():
	data.label = label_edit.text
	emit_signal("database_updated", data)
