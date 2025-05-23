@tool
class_name ReactionDatabase
extends Resource
## ----------------------------------------------------------------------------[br]
## Resource item to storage a reaction database.
##
## A database contains all the events and global facts and responses.
## available. [br]
## ----------------------------------------------------------------------------

const ReactionSettings = preload("../utilities/settings.gd")

@export var label: String

@export var uid: String = Uuid.v4()

## Events items of the reaction database
@export var events: Dictionary = {}

## Facts items of the reaction database
@export var global_facts: Dictionary = {}

## Tags of the reaction database
@export var tags: Dictionary = {}

## dictionary that store facts references logs
## each key is a fact value, and each value is a dict
var fact_log: Dictionary = {}



## ----------------------------------------------------------------------------[br]
## Create a clean fact and add it to the database 
## numbers [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func create_new_fact() -> void:
	var fact = ReactionFactItem.new()
	global_facts[fact.uid] = fact
	save_data()


## ----------------------------------------------------------------------------[br]
## Add a given fact to the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* fact | ReactionFactItem:[/b] New fact to add [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func add_fact(fact: ReactionFactItem) -> void:
	global_facts[fact.uid] = fact
	save_data()


## ----------------------------------------------------------------------------[br]
## Remove a given fact from the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* fact_uid | String:[/b] The fact's uid [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_fact(fact_uid: String) -> void:
	
	var fact: ReactionFactItem = global_facts.get(fact_uid, null)
	
	if fact:
		fact.update_tags()
		
	global_facts.erase(fact_uid)
	save_data()


## ----------------------------------------------------------------------------[br]
## Add a given event to the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* event | ReactionEventItem:[/b] New event to add [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func add_event(event: ReactionEventItem) -> void:
	events[event.uid] = event
	save_data()


## ----------------------------------------------------------------------------[br]
## Remove a given event from the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* event_uid | String:[/b] The event's uid [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_event(event_uid: String) -> void:
	events.erase(event_uid)
	save_data()
	
	
## ----------------------------------------------------------------------------[br]
## Add a given tag to the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* event | ReactionTag:[/b] New tag to add [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func add_tag(tag: ReactionTag) -> void:
	tags[tag.uid] = tag
	save_data()


## ----------------------------------------------------------------------------[br]
## Remove a given tag from the database
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* tag_uid | String:[/b] The tag's uid [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_tag(tag_uid: String) -> void:
	tags.erase(tag_uid)
	save_data()


## ----------------------------------------------------------------------------[br]
## Add a given rule to an event of the database. If event do not exists 
## on the database will be not added
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* event_uid | String:[/b] Event/s uid where add the rule [br]
## [b]* new_rule | ReactionRuleItem:[/b] New rule to be added [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func add_rule_to_event(event_uid: String, new_rule: ReactionRuleItem) -> void:
	if events.has(event_uid):
		var event: ReactionEventItem = events[event_uid]
		event.add_rule(new_rule)
		save_data()


## ----------------------------------------------------------------------------[br]
## Remove a given rule from an event of the database. If the event do not exists 
## on the database will be not removed.
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* event_uid | String:[/b] Event/s uid to remove the rule [br]
## [b]* rule_uid | String:[/b] Uid of the rule to remove [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_rule_from_event(event_uid: String, rule_uid: String) -> void:
	if events.has(event_uid):
		var event: ReactionEventItem = events[event_uid]
		event.remove_rule(rule_uid)
		save_data()
		
		
func add_fact_reference_log(object: ReactionReferenceLogItem) -> void:
	if object.object.parents and object.object.parents.size() > 0:
		var splited_parent: PackedStringArray = object.object.parents[0].split(":")
		var event_uid = splited_parent[1]
		events[event_uid].add_fact_reference_log(object)
	

func remove_fact_reference_log(item: Resource) -> void:
	if item.parents and item.parents.size() > 0:
		var splited_parent: PackedStringArray = item.parents[0].split(":")
		var event_uid = splited_parent[1]
		events[event_uid].remove_fact_reference_log(item)


## ----------------------------------------------------------------------------[br]
## Save the database to a file .tres on the path defined on the setting
## defined with name on DATABASES_PATH_SETTING_NAME. The file will be named
## with a combination of the database's name and the database's uid.
## [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
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


## ----------------------------------------------------------------------------[br]
## Remove the database's file .tres saved on the path defined on the setting
## defined with name on DATABASES_PATH_SETTING_NAME if exists. 
## [br]
## [b]Returns: void [br]
## ----------------------------------------------------------------------------
func remove_savedata() -> void:
	var databases_path = ReactionSettings.get_setting(
		ReactionSettings.DATABASES_PATH_SETTING_NAME,
		ReactionSettings.DATABASES_PATH_SETTING_DEFAULT
	)

	var file_path = "%s/%s_%s.tres" % [databases_path, label.replace(" ", "_"), uid]

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)


func _to_string():
	return "%s_%s" % [label, uid]
