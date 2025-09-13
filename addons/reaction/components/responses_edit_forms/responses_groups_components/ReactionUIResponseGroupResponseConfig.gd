@tool
extends HBoxContainer

@onready var response_name_lineedit: LineEdit = %ResponseNameLineEdit
@onready var response_uid_lineedit: LineEdit = %ResponseUidLineEdit

@onready var execution_order_container: VBoxContainer = %ExecutionOrderContainer
@onready var weigth_container: VBoxContainer = %WeightContainer

@onready var order_spinbox: SpinBox = %OrderSpinBox
@onready var return_once_check: CheckButton = %ReturnOnceCheckButton

var _current_data: Dictionary

func setup(response_group: ReactionResponseGroupItem, data: Dictionary):
	_current_data = data
	
	execution_order_container.visible = false
	weigth_container.visible = false
	
	if response_group.return_method == "order":
		execution_order_container.visible = true
	elif response_group.return_method == "random_weight":
		weigth_container.visible = true
	
	
	
