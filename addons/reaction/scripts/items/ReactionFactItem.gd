@tool
class_name ReactionFactItem
extends ReactionBaseItem
## ----------------------------------------------------------------------------[br]
## Resource item to storage and manage a fact.
##
## Class item to storage a possibe fact. A fact represent a state of the 
## game world [br]
## ----------------------------------------------------------------------------


## variant type of the fact
@export var type: Variant.Type

## if fact is enum, used when want to use a string label for fact value
@export var is_enum: bool = false:
	set(value):
		is_enum = value

		if Engine.is_editor_hint():
			notify_property_list_changed()

## if true when the fact value is modified on the blackboard reaction will trigger the global signal
## [b]blackboard_fact_modified[/b] 
@export var trigger_signal_on_modified: bool = false

## int string used when is_enum true to specify enum options
var hint_string: String:
	set(hs_value):
		hint_string = hs_value
		enum_names = hs_value.split(",")

var enum_names: PackedStringArray = []

## True if the fact have default value
var have_default_value: bool = false

## default value of the fact
var default_value: Variant

func have_references(database: ReactionDatabase) -> bool:
	for event in database.events.values():
		if uid in event.fact_reference_log:
			if event.fact_reference_log[uid].size() > 0:
				return true
		
	return false


func get_new_object():
	var new_fact = ReactionFactItem.new()
	new_fact.label = "newFact"
	new_fact.type = TYPE_STRING
	return new_fact
	
	
func update_tags():
	for tag in self.tags:
		tag.facts.erase(self.uid)
		

func _get_property_list() -> Array:
	var properties: Array = []

	var hint_string_usage = PROPERTY_USAGE_DEFAULT if is_enum else PROPERTY_USAGE_READ_ONLY

	properties.append_array(
		[{"name": "hint_string", "type": TYPE_STRING, "usage": hint_string_usage}]
	)

	return properties


func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.FACT
