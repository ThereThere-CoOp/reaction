@tool
class_name ReactionUIResponseGroupResponseConfig
extends HBoxContainer

@onready var response_name_lineedit: LineEdit = %ResponseNameLineEdit
@onready var response_uid_lineedit: LineEdit = %ResponseUidLineEdit

@onready var execution_order_container: VBoxContainer = %ExecutionOrderContainer
@onready var weigth_container: VBoxContainer = %WeightContainer
@onready var function_button: Button = %FunctionButton
@onready var function_confirmation_dialog: ConfirmationDialog = %FactsFunctionConfirmationDialog

@onready var order_spinbox: SpinBox = %OrderSpinBox
@onready var return_once_check: CheckButton = %ReturnOnceCheckButton

var order_line_edit: LineEdit

var _current_data: Dictionary

func setup(response_group: ReactionResponseGroupItem, data: Dictionary):
	response_name_lineedit = %ResponseNameLineEdit
	response_uid_lineedit = %ResponseUidLineEdit

	execution_order_container = %ExecutionOrderContainer
	weigth_container = %WeightContainer
	function_button = %FunctionButton
	function_confirmation_dialog = %FactsFunctionConfirmationDialog

	order_spinbox = %OrderSpinBox
	return_once_check = %ReturnOnceCheckButton

	_current_data = data
	
	order_line_edit = order_spinbox.get_line_edit()
	
	execution_order_container.visible = false
	weigth_container.visible = false
	
	if response_group.return_method == "order":
		execution_order_container.visible = true
	elif response_group.return_method == "random_weight":
		weigth_container.visible = true
	
	
	
