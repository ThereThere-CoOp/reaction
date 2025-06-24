@tool
class_name ReactionUIFunctionManagment
extends MarginContainer

@export var function_field_name: String = "function"

var object: ReactionBaseItem

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
var remove_button: Button

var function_label: RichTextLabel
var warning_label: RichTextLabel

var constant_confirm_dialog: ConfirmationDialog
var	fact_confirm_dialog: ConfirmationDialog

var constant_input: SpinBox
var fact_search_menu: ReactionUISearchMenu

	
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
	

func _check_function() -> bool:
	if current_function_array.size() > 0:
		var function_string = ";".join(current_function_array)
		var result = ReactionGlobals.get_function_result(function_string, null, true)
		if result == null:
			return false
	else:
		return false
			
	return true
	
	
	
func _update_warning_label():
	warning_label.visible = false
	if not _check_function():
		warning_label.visible = true
		warning_label.text = "[color=\"red\"]Invalid function[/color] "
		
		
func get_function_string():
	var result = ""
	
	for value in current_function_array:
		result += value + ";"
		
	return result.trim_suffix(";")
			
		
func setup(current_object: ReactionBaseItem):
	plus_button = %PlusButton
	minus_button = %MinusButton
	mult_button = %MultButton
	division_button = %DivisionButton
	left_parenthesis_button = %LeftParenthesisButton
	right_parenthesis_button = %RightParenthesisButton
	constant_button = %ConstantButton
	fact_button = %FactButton
	remove_button = %RemoveButton
	
	function_label = %FunctionText
	warning_label = %WarningLabel

	constant_confirm_dialog = %ConstantConfirmationDialog
	fact_confirm_dialog = %FactConfirmationDialog

	constant_input = %ConstantInput
	fact_search_menu = %FactSearchMenu
	
	OPERATOR_OPTIONS = ReactionGlobals.CRITERIA_FUNCTION_OPERATOR_OPTIONS
	
	object = current_object
	facts_list = ReactionFactItem.get_new_object().get_sqlite_list(null, true)
	fact_search_menu.items_list = facts_list
	
	if current_object:
		if object.get(function_field_name) != "":
			current_function_array = object.get(function_field_name).split(";")
		
	function_label.text = _generate_function_text()
		
		
### signals


func _on_plus_button_pressed() -> void:
	current_function_array.append("+")
	function_label.text = _generate_function_text()
	_update_warning_label()
	

func _on_minus_button_pressed() -> void:
	current_function_array.append("-")
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_mult_button_pressed() -> void:
	current_function_array.append("*")
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_division_button_pressed() -> void:
	current_function_array.append("/")
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_left_parenthesis_button_pressed() -> void:
	current_function_array.append("(")
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_right_parenthesis_button_pressed() -> void:
	current_function_array.append(")")
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_constant_button_pressed() -> void:
	constant_confirm_dialog.popup_centered()


func _on_fact_button_pressed() -> void:
	fact_confirm_dialog.popup_centered()


func _on_remove_button_pressed() -> void:
	current_function_array.pop_back()
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_constant_confirmation_dialog_confirmed() -> void:
	current_function_array.append(str(constant_input.value))
	function_label.text = _generate_function_text()
	_update_warning_label()


func _on_fact_confirmation_dialog_confirmed() -> void:
	var fact = fact_search_menu.current_item
	if fact:
		current_function_array.append(fact.uid)
		function_label.text = _generate_function_text()
	_update_warning_label()
