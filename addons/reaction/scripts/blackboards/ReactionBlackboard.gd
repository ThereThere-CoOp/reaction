class_name ReactionBlackboard
extends Resource
## ----------------------------------------------------------------------------[br]
## A context blackboard that stores several facts with the world state on a given
## context
##
## Store several facts that contains world state data on a given context and
## allow get easy access to the facts, add new facts and merge with others
## blackboard [br]
## ----------------------------------------------------------------------------

const ReactionSettings = preload("../../utilities/settings.gd")

## black board label
@export var label: String = "context_blackboard"

## list of facts
@export var facts: Array[ReactionBlackboardFact] = []

## dict wich each key is a fact id and the values are the current index on
## the _fact list, used for easy get the fact in the list
@export var facts_lookup = {}

## dict wich each key is a fact scope and each value
## with the facts id that belong to a given scope
@export var facts_scope_lookup = {}


func get_facts() -> Array[ReactionBlackboardFact]:
	return facts
	
	
func get_facts_lookup() -> Dictionary:
	return facts_lookup


func get_fact_value(fact_uid: String) -> Variant:
	if not facts_lookup.has(fact_uid):
		return null

	return facts[facts_lookup.get(fact_uid)].value


func get_blackboard_fact(fact_uid: String) -> ReactionBlackboardFact:
	if not facts_lookup.has(fact_uid):
		return null

	return facts[facts_lookup.get(fact_uid)]


## ----------------------------------------------------------------------------[br]
## Adds a value for a given fact into the blackboard if don't exists yet,
## if value exists on the blackboard update its value with the one
## passed as parameter. [br]
## ----------------------------------------------------------------------------
func set_fact_value(fact: ReactionFactItem, value: Variant) -> bool:
	var result = false
	var bfact = null
	if not facts_lookup.has(fact.uid):
		result = true
		bfact = ReactionBlackboardFact.new()
		# new_fact.value = int(value)
		bfact.fact = fact
		bfact.real_value = value
		facts.append(bfact)
		facts_lookup[fact.uid] = len(facts) - 1
	else:
		bfact = facts[facts_lookup.get(fact.uid)]
		# bfact.value = int(value)
		bfact.real_value = value

	## trigger blackboard fact modified signal if fact require it
	if fact.trigger_signal_on_modified:
		ReactionSignals.blackboard_fact_modified.emit(bfact, value)

	_add_facts_scope_lookup(fact)

	return result


## ----------------------------------------------------------------------------[br]
## Remove a fact from the blackboard [br]
## [b]Parameter(s):[/b] [br]
## [b]* fact_uid | String:[/b] Uid of the fact to remove [br]
## [b]Returns: bool[/b] [br]
## Returns true if fact exists on the blackboard and was erased
## succesfully  [br]
## ----------------------------------------------------------------------------
func erase_fact(fact_uid: String) -> bool:
	if not facts_lookup.has(fact_uid):
		return false

	var fact_index = facts_lookup[fact_uid]
	var fact_item = facts[fact_index].fact
	facts.remove_at(fact_index)
	facts_lookup.erase(fact_uid)
	_erase_facts_scope_lookup(fact_item)
	return true


## ----------------------------------------------------------------------------[br]
## Merge an array of blackboards on the blackboard that calls tbe function
## [b]Parameter(s):[/b][br]
## [b]* blackboards | Array[[ReactionBlackboard]]:[/b] Array of blackboards to be
## merge [br]
## [b]* overwrite | bool:[/b] If true the facts values on the result blackboard
## will be overwrote by the values passed on the parameter blackboards [br]
## [b]Returns: void[/b][br]
## ----------------------------------------------------------------------------
func merge(blackboards: Array[ReactionBlackboard], overwrite: bool = false) -> void:
	for blackboard: ReactionBlackboard in blackboards:
		for in_fact_uid in blackboard.facts_lookup:
			var in_fact_index = blackboard.facts_lookup[in_fact_uid]
			var in_fact = blackboard.facts[in_fact_index]
			
			var new_blackboard_fact: ReactionBlackboardFact = ReactionBlackboardFact.new()
			new_blackboard_fact.fact = in_fact.fact
			new_blackboard_fact.real_value = in_fact.real_value
			
			if facts_lookup.has(in_fact_uid):
				if overwrite:
					facts[facts_lookup.get(in_fact_uid)] = new_blackboard_fact

			else:
				facts.append(new_blackboard_fact)
				facts_lookup[in_fact_uid] = len(facts) - 1
				_add_facts_scope_lookup(new_blackboard_fact.fact)
				
				
func clone() -> ReactionBlackboard:
	var duplicate = ReactionBlackboard.new()
	duplicate.merge([self], true)
	return duplicate
	

## ----------------------------------------------------------------------------[br]
## Clean all the facts that belong to a scope from the blackboard [br]
## [b]Parameter(s):[/b] [br]
## [b]* scope | String:[/b] Label of the scope to clean [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func clean_scope(scope: String) -> void:
	if facts_scope_lookup.has(scope):
		var facts_uids = facts_scope_lookup[scope].duplicate()
		for uid in facts_uids:
			erase_fact(uid)
			
			
func save_data() -> void:
	var save_path_dir = ReactionSettings.get_setting(ReactionSettings.BLACKBOARDS_SAVE_PATHS_SETTINGS_NAME, ReactionSettings.BLACKBOARDS_SAVE_PATHS_DEFAULT)
	var save_path = save_path_dir + "/%s.tres" % label 
	var error = ResourceSaver.save(self, save_path)
	if error:
		print("An error happened while saving blackbord %s data: " % label, error)


func load_data() -> void:
	var save_path_dir = ReactionSettings.get_setting(ReactionSettings.BLACKBOARDS_SAVE_PATHS_SETTINGS_NAME, ReactionSettings.BLACKBOARDS_SAVE_PATHS_DEFAULT)
	var save_path = save_path_dir + "/%s.tres" % label 
	
	var save_context: ReactionBlackboard = load(save_path)
	label = save_context.name
	facts = save_context.facts
	facts_lookup = save_context.facts_lookup
	facts_scope_lookup = save_context.facts_scope_lookup


func _to_string() -> String:
	var result = ""
	for fact in facts:
		result += fact.get_string() + "\n"

	return result


func _erase_facts_scope_lookup(fact: ReactionFactItem) -> void:
	if facts_scope_lookup.has(fact.scope):
		facts_scope_lookup[fact.scope].erase(fact.uid)


func _add_facts_scope_lookup(fact: ReactionFactItem) -> void:
	if facts_scope_lookup.has(fact.scope):
		facts_scope_lookup[fact.scope].append(fact.uid)
	else:
		facts_scope_lookup[fact.scope] = [fact.uid]
