@tool
class_name ReactionCriteriaItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource to storage a rule criteria for a rule item.
##
## A rule criteria checks if a given fact value meets a condition. Is used
## to test if a rule match for a context data in a given time. [br]
## ----------------------------------------------------------------------------

const INT64_MIN = -(1 << 63)  # -9223372036854775808
const INT64_MAX = (1 << 63) - 1  # 9223372036854775807

## ----------------------------------------------------------------------------[br]
## Operation to use in criteria test. [br]
## [b]*[/b] The = check values are igual. [br]
## [b]*[/b] The < check that is less than or equal. [br]
## [b]*[/b] The > check that is greater than or equal. [br]
## [b]*[/b] The a<=x<=b check that the value is greater and iqual and less than
##	and equal than a value. [br]
## ----------------------------------------------------------------------------
@export_enum("=", "<", ">", "a<=x<=b") var operation: String:
	set(value):
		operation = value
		_update_internal_values()
		if Engine.is_editor_hint():
			notify_property_list_changed()

## If true negate the criteria
@export var is_reverse: bool = false

@export_group("Fact")
## Reaction fact to be used for the criteria
@export var fact: ReactionFactItem:
	set(value):
		fact = value
		if Engine.is_editor_hint():
			notify_property_list_changed()

@export_group("Criteria value(s)")
var value_a: Variant:  ## real criteria value manually introduced
	set = set_value_a,
	get = get_value_a
var value_b: Variant:  ## real b value manually introduced and used when operation is type a<=x<=b
	set = set_value_b,
	get = get_value_b
	
@export var value_a_int: int
@export var value_a_bool: bool
@export var value_a_string: String

@export var value_b_int: int
@export var value_b_bool: bool
@export var value_b_string: String

# internal values for a and b to be used on criteria
var _internal_value_a: int
var _internal_value_b: int


func _get_property_list() -> Array:
	var properties: Array = []
	
	if fact:
		var value_a_usage = (
			PROPERTY_USAGE_DEFAULT
			if (
				(fact != null and fact.type != null and not fact.is_enum)
				or (
					fact != null
					and fact.type != null
					and fact.is_enum
					and fact.hint_string
				)
			)
			else PROPERTY_USAGE_READ_ONLY
		)

		var value_a_hint = (
			PROPERTY_HINT_NONE if not fact.is_enum else PROPERTY_HINT_ENUM
		)
		var value_a_hint_string = "" if not fact.is_enum else fact.hint_string

		var value_b_usage = (
			PROPERTY_USAGE_DEFAULT
			if fact != null and fact.type != null and operation == "a<=x<=b"
			else PROPERTY_USAGE_READ_ONLY
		)

		properties.append_array(
			[
				{
					"name": "value_a",
					"type": fact.type,
					"usage": value_a_usage,
					"hint": value_a_hint,
					"hint_string": ""
				},
				{"name": "value_b", "type": fact.type, "usage": value_b_usage}
			]
		)
	else:
		properties.append_array(
			[
				{
					"name": "value_a",
					"type": TYPE_STRING,
					"usage": PROPERTY_USAGE_DEFAULT,
					"hint": "",
					"hint_string": ""
				},
				{"name": "value_b", "type": TYPE_STRING, "usage": PROPERTY_USAGE_DEFAULT}
			]
		)

	return properties


# -----------------------------------------------------------------------
# Update internal values for the given operation
#------------------------------------------------------------------------
func _update_internal_values() -> void:
	var current_value_a = value_a if value_a != null else INT64_MIN
	var current_value_b = value_b if value_b != null else INT64_MAX
	
	match operation:
		"<":
			_internal_value_a = INT64_MIN
			_internal_value_b = int(current_value_a)
		">":
			_internal_value_a = int(current_value_a)
			_internal_value_b = INT64_MAX
		"=":
			_internal_value_a = int(current_value_a)
			_internal_value_b = int(current_value_a)
		"a<=x<=b":
			_internal_value_a = int(current_value_a)
			_internal_value_b = int(current_value_b)
		_:
			_internal_value_a = int(current_value_a)
			_internal_value_b = int(current_value_a)


func set_value_a(value: Variant) -> void:
	value_a = value
	
	if fact:
		match fact.type:
			TYPE_STRING:
				value_a_string = str(value)
			TYPE_BOOL:
				value_a_bool = value
			TYPE_INT:
				value_a_int = value
			_:
				value_a_int = value
	else:
		if self is ReactionFunctionCriteriaItem:
			value_a_int = value
				
	_update_internal_values()


func get_value_a() -> Variant:
	if value_a:
		return value_a
	else:
		if fact:
			match fact.type:
				TYPE_STRING:
					return value_a_string
				TYPE_BOOL:
					return value_a_bool
				TYPE_INT:
					return value_a_int
				_:
					return value_a_int
		else:
			if self is ReactionFunctionCriteriaItem:
				return value_a_int
				
	return null
		


func set_value_b(value: Variant) -> void:
	value_b = value
	
	if fact:
		match fact.type:
			TYPE_STRING:
				value_b_string = value
			TYPE_BOOL:
				value_b_bool = value
			TYPE_INT:
				value_b_int = value
			_:
				value_b_int = value
	else:
		if self is ReactionFunctionCriteriaItem:
			value_b_int = value

	_update_internal_values()


func get_value_b() -> Variant:
	if value_b:
		return value_b
	else:
		if fact:
			match fact.type:
				TYPE_STRING:
					return value_b_string
				TYPE_BOOL:
					return value_b_bool
				TYPE_INT:
					return value_b_int
				_:
					return value_b_int
		else:
			if self is ReactionFunctionCriteriaItem:
				return value_b_int
				
	return null


## ----------------------------------------------------------------------------[br]
## Tests if the criteria match with a blackboard fact [br]
## [b]Parameter(s):[/b] [br]
## [b]* blackboard_fact | [ReactionBlackboardFact]:[/b] Blackboard fact value to
## test with the criteria [br]
## [b]Returns: bool[/b] [br]
## Returns true if criteria match with fact value  [br]
## ----------------------------------------------------------------------------
func test(context: ReactionBlackboard) -> bool:
	var b_fact: ReactionBlackboardFact = context.get_blackboard_fact(fact.uid)
	
	# if criteria fact do not exists on blackboard
	# rule do not match
	if b_fact == null:
			return false
			
	var criteria_test_result = (
		b_fact.value >= _internal_value_a
		and b_fact.value <= _internal_value_b
	)
	
	return criteria_test_result if not is_reverse else not criteria_test_result
	
	
func get_new_object() -> ReactionCriteriaItem:
	return ReactionCriteriaItem.new()
	

func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.CRITERIA
