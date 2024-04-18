@tool
class_name ReactionContextModification
extends Resource
## ----------------------------------------------------------------------------[br]
## Resource to storage and assing modifications to blackboard fact values.
##
## A context modification define how certain fact value would be modified
## on the blackboard context when a given rule is selected
## and any further detail.
## ----------------------------------------------------------------------------

## label the identify modification used as a short description
@export_group("General")
@export var label: String

## fact resource to modify
@export_group("Fact")
@export var fact: ReactionFactItem:
	set(value):
		fact = value
		if Engine.is_editor_hint():
			notify_property_list_changed()

@export_group("Modification value")
var modification_value: Variant:  ## Value to be used with the operation to modify
	set(value):
		modification_value = value

var operation: String:  ## Operation of the modification
	set(value):
		operation = value
		if Engine.is_editor_hint():
			notify_property_list_changed()


func _get_property_list() -> Array:
	var properties: Array = []

	var numeric_operations_string_hints = "+,-,=,erase"
	var default_operations_string_hints = "=,erase"

	var modification_value_usage = (
		PROPERTY_USAGE_DEFAULT if fact != null and fact.type != null else PROPERTY_USAGE_READ_ONLY
	)

	var operation_usage = (
		PROPERTY_USAGE_DEFAULT if fact != null and fact.type != null else PROPERTY_USAGE_READ_ONLY
	)

	var operation_string_hint = (
		numeric_operations_string_hints
		if fact.type == TYPE_INT or fact.type == TYPE_FLOAT
		else default_operations_string_hints
	)

	properties.append_array(
		[
			{"name": "modification_value", "type": fact.type, "usage": modification_value_usage},
			{
				"name": "operation",
				"type": TYPE_STRING,
				"usage": operation_usage,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": operation_string_hint
			}
		]
	)

	return properties

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
			if fact and modification_value != null:
				context.set_fact_value(fact, modification_value)
		"-":
			if fact and modification_value != null:
				var current_value = context.get_fact_value(fact.uid)
				var new_value = (
					current_value - modification_value
					if current_value != null
					else -(modification_value)
				)
				context.set_fact_value(fact, new_value)
		"+":
			if fact and modification_value != null:
				var current_value = context.get_fact_value(fact.uid)
				var new_value = (
					current_value + modification_value
					if current_value != null
					else modification_value
				)
				context.set_fact_value(fact, new_value)
