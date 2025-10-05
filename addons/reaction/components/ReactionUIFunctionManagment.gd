@tool
class_name ReactionUIFunctionManagment
extends MarginContainer

@export var function_field_name: String = "function"

## math methods config
var math_methods_config = {
	"pow": [{"operand_name": "Base", "internal_name": "BASE"}, {"operand_name": "Exponent", "internal_name": "EXP"}],
	"sqrt": [{"operand_name": "Number", "internal_name": "NUMBER"}],
}

var object_data: Dictionary

var current_function_array = []

var facts_list = []

var OPERATOR_OPTIONS: Dictionary

var plus_button: Button
var minus_button: Button
var mult_button: Button
var division_button: Button
var left_parenthesis_button: Button
var right_parenthesis_button: Button
var constant_button: Button
var fact_button: Button
var pow_button: Button
var sqrt_button: Button
var remove_button: Button

var math_method_helper_label: RichTextLabel
var math_method_controls_help_label: RichTextLabel

var function_label: RichTextLabel
var warning_label: RichTextLabel

var constant_confirm_dialog: ConfirmationDialog
var	fact_confirm_dialog: ConfirmationDialog

var constant_input: SpinBox
var fact_search_menu: ReactionUISearchMenu

var _use_math_method_mode = false

var _current_math_method = ""

var _current_math_method_operands_indexes = []

var _current_math_method_operand_index = 0


func _generate_function_text() -> String:
	var text_result = ""
	for operator in current_function_array:
		if operator.is_valid_float() or OPERATOR_OPTIONS.has(operator):
			text_result += "%s" % [operator]
		else:
			facts_list = ReactionFactItem.get_new_object().get_sqlite_list("uid = '%s'" % [operator], false)
			if facts_list.size() > 0:
				text_result += "[color=\"yellow\"]%s[/color] " % [facts_list[0].label]
			else:
				text_result += "[color=\"red\"]<not_found>[/color] "
			
	return text_result
	

func check_function() -> bool:
	if current_function_array.size() > 0:
		var function_string = ";".join(current_function_array)
		var result = ReactionUtilities.get_function_result(function_string, null, true)
		if result == null:
			return false
	else:
		return true
			
	return true
	
	
func _enable_disable_buttons():
	math_method_helper_label.visible = false
	math_method_controls_help_label.visible = false
	
	plus_button.disabled = false
	minus_button.disabled = false
	mult_button.disabled = false
	division_button.disabled = false
	left_parenthesis_button.disabled = false
	right_parenthesis_button.disabled = false
	constant_button.disabled = false
	fact_button.disabled = false
	pow_button.disabled = false
	sqrt_button.disabled = false
	remove_button.disabled = false
	
	if _use_math_method_mode:
		math_method_helper_label.visible = true
		math_method_controls_help_label.visible = true
	
		plus_button.disabled = true
		minus_button.disabled = true
		mult_button.disabled = true
		division_button.disabled = true
		left_parenthesis_button.disabled = true
		right_parenthesis_button.disabled = true
		pow_button.disabled = true
		sqrt_button.disabled = true
		

func _init_math_method_mode():
	_use_math_method_mode = false
	_current_math_method_operand_index = 0
	_current_math_method = ""
	_current_math_method_operands_indexes = []
	_enable_disable_buttons()
	
	
func _update_method_math_mode():
	var method_operands = math_methods_config.get(_current_math_method, [])
	_current_math_method_operand_index += 1
	
	if _current_math_method_operand_index >= method_operands.size():
		_init_math_method_mode()
		
		
func _add_initial_math_method():
	var method_operands = math_methods_config.get(_current_math_method, [])
	
	current_function_array.append(_current_math_method)
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("(", ""))
	for operand in method_operands:
		current_function_array.append(operand.get("internal_name", "X"))
		_current_math_method_operands_indexes.append(current_function_array.size() - 1)
		current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get(",", ""))
	
	current_function_array.pop_back()
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get(")", ""))
	
	
func _update_math_method_operand_label():
	var method_operands = math_methods_config.get(_current_math_method, [])
	
	var text = """Add operand: [color="yellow"]%s[/color]""" % method_operands[_current_math_method_operand_index].get("operand_name", "")
	math_method_helper_label.text = text
	

func _update_operand_value_in_function(value):
	var method_operands = math_methods_config.get(_current_math_method, [])
	current_function_array[_current_math_method_operands_indexes[_current_math_method_operand_index]] = value
	

func _add_numeric_value_to_function(value):
	if not _use_math_method_mode:
		current_function_array.append(value)
	else:
		_update_operand_value_in_function(value)
		_update_method_math_mode()
			
		if _use_math_method_mode:
			_update_math_method_operand_label()
			
	function_label.text = _generate_function_text()
	_update_warning_label()
	
	
func _update_warning_label():
	warning_label.visible = false
	if not check_function():
		warning_label.visible = true
		warning_label.text = "[color=\"red\"]Invalid function[/color] "
		
		
func get_function_string():
	var result = ""
	
	for value in current_function_array:
		result += value + ";"
		
	return result.trim_suffix(";")
			
		
func setup(current_object: Dictionary):
	plus_button = %PlusButton
	minus_button = %MinusButton
	mult_button = %MultButton
	division_button = %DivisionButton
	left_parenthesis_button = %LeftParenthesisButton
	right_parenthesis_button = %RightParenthesisButton
	constant_button = %ConstantButton
	fact_button = %FactButton
	pow_button = %PowButton
	sqrt_button = %SqrtButton
	remove_button = %RemoveButton
	
	math_method_helper_label = %MathMethodHelperLabel
	math_method_controls_help_label = %MathMethodControlsHelpLabel

	function_label = %FunctionText
	warning_label = %WarningLabel

	constant_confirm_dialog = %ConstantConfirmationDialog
	fact_confirm_dialog = %FactConfirmationDialog

	constant_input = %ConstantInput
	fact_search_menu = %FactSearchMenu
	
	_use_math_method_mode = false
	_current_math_method = ""
	_current_math_method_operand_index = 0
	
	OPERATOR_OPTIONS = ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS
	
	object_data = current_object
	facts_list = ReactionFactItem.get_new_object().get_sqlite_list(null, true)
	fact_search_menu.items_list = facts_list
	
	if object_data:
		var object_function = object_data.get(function_field_name)
		if object_function != "" and object_function != null:
			current_function_array = Array(object_function.split(";"))
		else:
			current_function_array = []
		
	function_label.text = _generate_function_text()
	_update_warning_label()
	_init_math_method_mode()
		
		
### signals

func _on_plus_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("+", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()
	

func _on_minus_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("-", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_mult_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("*", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_division_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("/", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_left_parenthesis_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("(", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_right_parenthesis_button_pressed() -> void:
	current_function_array.append(ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get(")", ""))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_constant_button_pressed() -> void:
	constant_confirm_dialog.popup_centered()


func _on_fact_button_pressed() -> void:
	fact_confirm_dialog.popup_centered()


func _on_remove_button_pressed() -> void:
	if not _use_math_method_mode:
		current_function_array.resize(current_function_array.size() - 1)
	else:
		var method_operands = math_methods_config.get(_current_math_method, [])
		var rezise_value = current_function_array.size() - (3 + (method_operands.size() * 2 - 1))
		current_function_array.resize(rezise_value)
		_init_math_method_mode()
		
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_constant_confirmation_dialog_confirmed() -> void:
	_add_numeric_value_to_function(str(constant_input.value))


func _on_fact_confirmation_dialog_confirmed() -> void:
	var fact = fact_search_menu.current_item
	if fact:
		_add_numeric_value_to_function(fact.uid)


func _on_pow_button_pressed() -> void:
	_use_math_method_mode = true
	_current_math_method = ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("pow", "")
	_enable_disable_buttons()
	_add_initial_math_method()
	_update_math_method_operand_label()
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_sqrt_button_pressed() -> void:
	_use_math_method_mode = true
	_current_math_method = ReactionConstants.CRITERIA_FUNCTION_OPERATOR_OPTIONS.get("sqrt", "")
	_enable_disable_buttons()
	_add_initial_math_method()
	_update_math_method_operand_label()
	function_label.text = _generate_function_text()
	_update_warning_label()
