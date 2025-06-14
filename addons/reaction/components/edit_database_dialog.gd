@tool
extends ConfirmationDialog

signal database_updated(database: SQLite)

var database: SQLite = null

@onready var label_edit: LineEdit = %DatabaseNameLineEdit


func _ready() -> void:
	register_text_enter(label_edit)


func edit_database(database_id: String) -> void:
	if database_id != null:
		label_edit.text = database_id
	
	
	popup_centered()
	label_edit.grab_focus()
	label_edit.select_all()


### Signals

func _on_edit_board_dialog_confirmed():
	data.label = label_edit.text
	database_updated.emit(data)
