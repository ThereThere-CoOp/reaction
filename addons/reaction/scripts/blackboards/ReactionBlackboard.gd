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

## list of facts
var _facts: Array[ReactionBlackboardFact] = []

## dict wich each key is a fact id and the values are the current index on
## the _fact list, used for easy get the fact in the list
var _facts_lookup = {}

## dict wich each key is a fact scope and each value
## with the facts id that belong to a given scope
var _facts_scope_lookup = {}


func get_facts() -> Array[ReactionBlackboardFact]:
	return _facts
	
	
func get_facts_lookup() -> Dictionary:
	return _facts_lookup


func get_fact_value(fact_uid: String) -> Variant:
	if not _facts_lookup.has(fact_uid):
		return null

	return _facts[_facts_lookup.get(fact_uid)].value


func get_blackboard_fact(fact_uid: String) -> ReactionBlackboardFact:
	if not _facts_lookup.has(fact_uid):
		return null

	return _facts[_facts_lookup.get(fact_uid)]


## ----------------------------------------------------------------------------[br]
## Adds a value for a given fact into the blackboard if don't exists yet,
## if value exists on the blackboard update its value with the one
## passed as parameter. [br]
## ----------------------------------------------------------------------------
func set_fact_value(fact: ReactionFactItem, value: Variant) -> bool:
	var result = false
	var bfact = null
	if not _facts_lookup.has(fact.uid):
		result = true
		bfact = ReactionBlackboardFact.new()
		# new_fact.value = int(value)
		bfact.fact = fact
		bfact.real_value = value
		_facts.append(bfact)
		_facts_lookup[fact.uid] = len(_facts) - 1
	else:
		bfact = _facts[_facts_lookup.get(fact.uid)]
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
	if not _facts_lookup.has(fact_uid):
		return false

	var fact_index = _facts_lookup[fact_uid]
	var fact_item = _facts[fact_index].fact
	_facts.remove_at(fact_index)
	_facts_lookup.erase(fact_uid)
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
	for blackboard in blackboards:
		for in_fact_uid in blackboard._facts_lookup:
			var in_fact_index = blackboard._facts_lookup[in_fact_uid]
			var in_fact = blackboard._facts[in_fact_index]
			
			var new_blackboard_fact: ReactionBlackboardFact = ReactionBlackboardFact.new()
			new_blackboard_fact.fact = in_fact.fact
			new_blackboard_fact.real_value = in_fact.real_value
			
			if _facts_lookup.has(in_fact_uid):
				if overwrite:
					_facts[_facts_lookup.get(in_fact_uid)] = new_blackboard_fact

			else:
				_facts.append(new_blackboard_fact)
				_facts_lookup[in_fact_uid] = len(_facts) - 1
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
	if _facts_scope_lookup.has(scope):
		var facts_uids = _facts_scope_lookup[scope].duplicate()
		for uid in facts_uids:
			erase_fact(uid)


func _to_string() -> String:
	var result = ""
	for fact in _facts:
		result += fact.get_string() + "\n"

	return result


func _erase_facts_scope_lookup(fact: ReactionFactItem) -> void:
	if _facts_scope_lookup.has(fact.scope):
		_facts_scope_lookup[fact.scope].erase(fact.uid)


func _add_facts_scope_lookup(fact: ReactionFactItem) -> void:
	if _facts_scope_lookup.has(fact.scope):
		_facts_scope_lookup[fact.scope].append(fact.uid)
	else:
		_facts_scope_lookup[fact.scope] = [fact.uid]
