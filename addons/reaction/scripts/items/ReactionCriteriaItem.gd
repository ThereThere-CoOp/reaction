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

var fact_script: ReactionFactItem = ReactionFactItem.get_new_object()

@export_group("Criteria value(s)")
@export var value_a: String:  ## real criteria value manually introduced
	set = set_value_a,
	get = get_value_a
@export var value_b: String:  ## real b value manually introduced and used when operation is type a<=x<=b
	set = set_value_b,
	get = get_value_b

# internal values for a and b to be used on criteria
var _internal_value_a: int
var _internal_value_b: int


func _init() -> void:
	super()
	label = "new_criteria"
	sqlite_table_name = "criteria"
	# reaction_item_type = ReactionGlobals.ItemsTypesEnum.CRITERIA


#func _get_property_list() -> Array:
	#var properties: Array = []
	#
	#if fact:
		#var value_a_usage = (
			#PROPERTY_USAGE_DEFAULT
			#if (
				#(fact != null and fact.type != null and not fact.is_enum)
				#or (
					#fact != null
					#and fact.type != null
					#and fact.is_enum
					#and fact.hint_string
				#)
			#)
			#else PROPERTY_USAGE_READ_ONLY
		#)
#
		#var value_a_hint = (
			#PROPERTY_HINT_NONE if not fact.is_enum else PROPERTY_HINT_ENUM
		#)
		#var value_a_hint_string = "" if not fact.is_enum else fact.hint_string
#
		#var value_b_usage = (
			#PROPERTY_USAGE_DEFAULT
			#if fact != null and fact.type != null and operation == "a<=x<=b"
			#else PROPERTY_USAGE_READ_ONLY
		#)
#
		#properties.append_array(
			#[
				#{
					#"name": "value_a",
					#"type": fact.type,
					#"usage": value_a_usage,
					#"hint": value_a_hint,
					#"hint_string": ""
				#},
				#{"name": "value_b", "type": fact.type, "usage": value_b_usage}
			#]
		#)
	#else:
		#properties.append_array(
			#[
				#{
					#"name": "value_a",
					#"type": TYPE_STRING,
					#"usage": PROPERTY_USAGE_DEFAULT,
					#"hint": "",
					#"hint_string": ""
				#},
				#{"name": "value_b", "type": TYPE_STRING, "usage": PROPERTY_USAGE_DEFAULT}
			#]
		#)
#
	#return properties


# -----------------------------------------------------------------------
# Update internal values for the given operation
#------------------------------------------------------------------------
func _update_internal_values() -> void:
	var current_value_a = get_real_value(value_a) if value_a != null else INT64_MIN
	var current_value_b = get_real_value(value_b) if value_b != null else INT64_MAX
	
	if fact and fact.type == TYPE_STRING and not fact.is_enum:
		current_value_a = hash(current_value_a)
		current_value_b = hash(current_value_b)
	
	match operation:
		"<":
			_internal_value_a = INT64_MIN
			if current_value_a:
				_internal_value_b = current_value_a
		">":
			if current_value_a:
				_internal_value_a = current_value_a
			_internal_value_b = INT64_MAX
		"=":
			if current_value_a:
				_internal_value_a = current_value_a
				_internal_value_b = current_value_a
		"a<=x<=b":
			if current_value_a:
				_internal_value_a = current_value_a
			if current_value_b:
				_internal_value_b = current_value_b
		_:
			if current_value_a:
				_internal_value_a = current_value_a
				_internal_value_b = current_value_a


func set_value_a(value: String) -> void:
	value_a = value
				
	_update_internal_values()

func get_value_a():
	return value_a
	
func get_value_b():
	return value_b
	
func get_real_value(value) -> Variant:
	
	if fact:
		match fact.type:
			TYPE_STRING:
				if fact.is_enum:
					return fact.enum_names.find(value)
				else:
					return value
			TYPE_BOOL:
				return ReactionUtilities.get_boolean_from_string(value)
			TYPE_INT:
				if value:
					return int(value)
			_:
				return value
	else:
		if self is ReactionFunctionCriteriaItem:
			if value:
				return int(value)
				
	return null
		


func set_value_b(value: String) -> void:
	value_b = value

	_update_internal_values()


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
			
	#print(is_reverse)
	#print("Criteria values %s " % [label], b_fact.value, " ", _internal_value_a, " ", value_a)
	
	var criteria_test_result = (
		b_fact.value >= _internal_value_a
		and b_fact.value <= _internal_value_b
	)
	
	return criteria_test_result if not is_reverse else not criteria_test_result
	
	
static func get_new_object():
	return ReactionCriteriaItem.new()
	

func get_type_string() -> int:
	return ReactionConstants.ITEMS_TYPE_ENUM.CRITERIA
