@tool
class_name ReactionContextModificationItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource to storage and assing modifications to blackboard fact values.
##
## A context modification define how certain fact value would be modified
## on the blackboard context when a given rule is selected
## and any further detail.
## ----------------------------------------------------------------------------

## fact resource to modify
@export_group("Fact")
@export var fact: ReactionFactItem:
	set(value):
		fact = value
		if Engine.is_editor_hint():
			notify_property_list_changed()

var fact_script: ReactionFactItem = ReactionFactItem.get_new_object()

@export_group("Modification value")
@export var modification_value: String ## Value to be used with the operation to modify
		

func get_modification_real_value():
	if fact:
		if fact.type == TYPE_STRING:
			return modification_value
		elif fact.type == TYPE_INT:
			return int(modification_value)
		elif fact.type == TYPE_BOOL:
			return !!int(modification_value)
		else:
			return modification_value
	else:
		return modification_value

@export var operation: String:  ## Operation of the modification
	set(value):
		operation = value
		if Engine.is_editor_hint():
			notify_property_list_changed()
			
@export var function: String = ""

@export var is_function: bool = false		

func _init() -> void:
	super()
	sqlite_table_name = "modification"
	label = "new_modification"
	


#func _get_property_list() -> Array:
	#var properties: Array = []
	#
	#if fact:
		#var numeric_operations_string_hints = "+,-,=,erase"
		#var default_operations_string_hints = "=,erase"
#
		#var modification_value_usage = (
			#PROPERTY_USAGE_DEFAULT if fact != null and fact.type != null else PROPERTY_USAGE_READ_ONLY
		#)
#
		#var operation_usage = (
			#PROPERTY_USAGE_DEFAULT if fact != null and fact.type != null else PROPERTY_USAGE_READ_ONLY
		#)
#
		#var operation_string_hint = (
			#numeric_operations_string_hints
			#if fact.type == TYPE_INT or fact.type == TYPE_FLOAT
			#else default_operations_string_hints
		#)
#
		#properties.append_array(
			#[
				#{"name": "modification_value", "type": fact.type, "usage": modification_value_usage},
				#{
					#"name": "operation",
					#"type": TYPE_STRING,
					#"usage": operation_usage,
					#"hint": PROPERTY_HINT_ENUM,
					#"hint_string": operation_string_hint
				#}
			#]
		#)
#
	#return properties
	
	
func _get_modification_value(context):
	if is_function:
		return int(ReactionUtilities.get_function_result(function, context, false))
	else:
		return get_modification_real_value()
		

## ----------------------------------------------------------------------------[br]
## Executes the modification changing the fact value on the current context [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Context to modify [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func execute(context: ReactionBlackboard) -> void:
	match operation:
		"erase":
			if fact:
				context.erase_fact(fact.uid)
		"=":
			var current_mod_value = _get_modification_value(context)
			if fact and current_mod_value != null:
				context.set_fact_value(fact, current_mod_value)
		"-":
			var current_mod_value = _get_modification_value(context)
			if fact and current_mod_value != null:
				var current_value = context.get_fact_value(fact.uid)
				var new_value = (
					current_value - current_mod_value
					if current_value != null
					else -(current_mod_value)
				)
				context.set_fact_value(fact, new_value)
		"+":
			var current_mod_value = _get_modification_value(context)
			if fact and current_mod_value != null:
				var current_value = context.get_fact_value(fact.uid)
				var new_value = (
					current_value + current_mod_value
					if current_value != null
					else current_mod_value
				)
				context.set_fact_value(fact, new_value)

				
static func get_new_object():
	return ReactionContextModificationItem.new()
	
	
func get_type_string() -> int:
	return ReactionConstants.ITEMS_TYPE_ENUM.MODIFICATION
