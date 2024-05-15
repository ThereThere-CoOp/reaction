@tool
class_name ReactionDatabase
extends Resource

const ReactionSettings = preload("../utilities/settings.gd")

@export var label: String

@export var uid: String = Uuid.v4()

@export var events: Dictionary = {}

@export var global_facts: Dictionary = {}


func create_new_fact():
	var fact = ReactionFactItem.new()
	global_facts[fact.uid] = fact
	save_data()


func add_fact(fact: ReactionFactItem):
	global_facts[fact.uid] = fact
	save_data()


func remove_fact(fact_uid: String):
	global_facts.erase(fact_uid)
	save_data()
	

func add_event(event: ReactionEventItem):
	events[event.uid] = event
	save_data()
	
	
func remove_event(event_uid: String) -> void:
	events.erase(event_uid)
	save_data()
	
	
func add_rule_to_event(event_uid: String, rule_uid: String) -> void:
	var event: ReactionEventItem = events[event_uid]
	event.remove_rule(rule_uid)
	save_data()
	
	
func remove_rule_from_event(event_uid: String, new_rule: ReactionRuleItem) -> void:
	var event: ReactionEventItem = events[event_uid]
	event.add_rule(new_rule)
	save_data()


func save_data() -> void:
	ResourceSaver.save(
		self,
		(
			"%s/%s_%s.tres"
			% [
				ReactionSettings.get_setting(
					ReactionSettings.DATABASES_PATH_SETTING_NAME,
					ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
				),
				label.replace(" ", "_"),
				uid
			]
		)
	)


func remove_savedata() -> void:
	var databases_path = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)

	var file_path = (
		"%s/%s_%s.tres" % [databases_path, label.replace(" ", "_"), uid]
	)

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)

func _to_string():
	return "%s_%s" % [label, uid]
