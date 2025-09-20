@tool
class_name ReactionUIResponseGroupResponseConfig
extends PanelContainer

@onready var response_name_lineedit: LineEdit = %ResponseNameLineEdit
@onready var response_uid_lineedit: LineEdit = %ResponseUidLineEdit

@onready var execution_order_container: VBoxContainer = %ExecutionOrderContainer
@onready var weigth_container: VBoxContainer = %WeightContainer
@onready var function_button: Button = %FunctionButton
@onready var function_confirmation_dialog: ConfirmationDialog = %FactsFunctionConfirmationDialog
@onready var weight_function_managment: ReactionUIFunctionManagment = %FunctionManagment
@onready var order_spinbox: SpinBox = %OrderSpinBox
@onready var return_once_check: CheckButton = %ReturnOnceCheckButton

var order_line_edit: LineEdit

var _current_data: Dictionary

var _sqlite_database: SQLite


func _set_response_configuration(property_name: StringName, value: Variant) -> void:
	var where = "id = %d" % _current_data.get("relation_id", 0)
	
	_current_data.set(property_name, value)
	var update_data = {}
	update_data.set(property_name, value)
	_sqlite_database.update_rows("response_parent_group_rel", where,  update_data)


func change_inputs_visibility(response_group: ReactionResponseGroupItem) -> void:
	execution_order_container.visible = false
	weigth_container.visible = false
	
	if response_group.return_method == "order":
		execution_order_container.visible = true
	elif response_group.return_method == "random_weight":
		weigth_container.visible = true
		
		
func setup(response_group: ReactionResponseGroupItem, data: Dictionary) -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database
	response_name_lineedit = %ResponseNameLineEdit
	response_uid_lineedit = %ResponseUidLineEdit

	execution_order_container = %ExecutionOrderContainer
	weigth_container = %WeightContainer
	function_button = %FunctionButton
	weight_function_managment = %FunctionManagment
	function_confirmation_dialog = %FactsFunctionConfirmationDialog

	order_spinbox = %OrderSpinBox
	return_once_check = %ReturnOnceCheckButton

	_current_data = data
	
	order_line_edit = order_spinbox.get_line_edit()
	
	change_inputs_visibility(response_group)
	
	response_name_lineedit.text = data.get("label", "")
	response_uid_lineedit.text = data.get("uid", "")
	
	return_once_check.set_pressed_no_signal(data.get("return_once", false))
	order_spinbox.set_value_no_signal(int(data.get("execution_order", 0)))
	
	# connect signals
	order_line_edit.text_submitted.connect(_on_order_line_edit_text_submitted)
	
	
# signals
func _on_function_button_pressed() -> void:
	weight_function_managment.setup(_current_data)
	function_confirmation_dialog.popup_centered()


func _on_return_once_check_button_toggled(toggled_on: bool) -> void:
	_set_response_configuration("return_once", toggled_on)
	

func _on_order_line_edit_text_submitted(text: String):
	_set_response_configuration("execution_order", int(text))
	order_line_edit.release_focus()


func _on_facts_function_confirmation_dialog_confirmed() -> void:
	if weight_function_managment.check_function():
		_set_response_configuration("weight_function", weight_function_managment.get_function_string())
