@tool
extends Window


@onready var event_log_list: ItemList = %EventLogItemList
@onready var event_log_data_container: MarginContainer = %EventLogDataContainer

@onready var event_label_edit: LineEdit = %EventLabelLineEdit
@onready var event_uid_edit: LineEdit = %EventUidLineEdit

@onready var rule_label_edit: LineEdit = %RuleLabelLineEdit
@onready var rule_uid_edit: LineEdit = %RuleUidLineEdit

@onready var trigger_event_label_edit: LineEdit = %TriggerEventLabelLineEdit
@onready var trigger_event_uid_edit: LineEdit = %TriggerEventUidLineEdit

@onready var trigger_rule_label_edit: LineEdit = %TriggerRuleLabelLineEdit
@onready var trigger_rule_uid_edit: LineEdit = %TriggerRuleUidLineEdit

@onready var criterias_data_label: RichTextLabel = %CriteriasDataLabel
@onready var modifications_data_label: RichTextLabel = %ModificationsDataLabel

@onready var blackboard_data_label: RichTextLabel = %BlackboardDataLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	ReactionSignals.event_execution_log_created.connect(add_event_log)
	event_log_data_container.visible = false
	
	clear()
	
	
func add_event_log(new_event_log: ReactionEventExecutionLogItem) -> void:
	var current_index: int = event_log_list.add_item(new_event_log.label)
	event_log_list.set_item_metadata(current_index, new_event_log)
	
	
func clear() -> void:
	event_log_list.clear()
	event_log_data_container.visible = false
	
	
func _update_criterias(criterias: Array[ReactionCriteriaItem]) -> void:
	if criterias and criterias.size() > 0:
		var result: String = ""
		for criteria: ReactionCriteriaItem in criterias:
			result += "[color=yellow]%s:[/color] Fact: [color=yellow]%s[/color] %s %s \n" % [criteria.label, criteria.fact.label, criteria.operation,  str(criteria.value)]
		criterias_data_label.text = "[code]%s[/code]" % result
	else:
		criterias_data_label.text = "[code]No criterias found[/code]"
		
		
func _update_modifications(modifications: Array[ReactionContextModificationItem]) -> void:
	if modifications and modifications.size() > 0:
		var result: String = ""
		for modification: ReactionContextModificationItem in modifications:
			result += "[color=yellow]%s:[/color] Fact: [color=yellow]%s[/color] %s %s \n" % [modification.label, modification.fact.label, modification.operation,  str(modification.modification_value)]
		modifications_data_label.text = "[code]%s[/code]" % result
	else:
		modifications_data_label.text = "[code]No modifications found[/code]"
		
	
func _update_blackboard_data(old_blackboard: ReactionBlackboard, new_blackboard: ReactionBlackboard) -> void:
	var result_dict = {}
	
	var new_blackboard_facts = new_blackboard.get_facts()
	var new_blackboard_facts_dict = new_blackboard.get_facts_lookup()
	
	for old_value: ReactionBlackboardFact in old_blackboard.get_facts():
		result_dict[old_value.fact.uid] = "[color=yellow]%s:[/color] %s -> " % [old_value.fact.label, str(old_value.real_value)]
		if old_value.fact.uid not in new_blackboard_facts_dict:
			# old value do not exists on new blackboard
			result_dict[old_value.fact.uid] += "[color=red][s]null[/s][/color]\n"
		else:
			# old value exists on new blackboard
			var new_fact_value = new_blackboard_facts[new_blackboard_facts_dict[old_value.fact.uid]]
			if old_value.value == new_fact_value.value:
				# the values are equal
				result_dict[old_value.fact.uid] += "%s\n" % new_fact_value.real_value
			else:
				# the values are different
				result_dict[old_value.fact.uid] += "[color=yellow]%s[/color]\n" % new_fact_value.real_value
				
	for new_value: ReactionBlackboardFact in new_blackboard_facts:
		if new_value.fact.uid not in result_dict:
			result_dict[new_value.fact.uid] = "[color=yellow]%s:[/color] [s]null[/s] -> [color=green]%s[/color]\n" % [new_value.fact.label, str(new_value.real_value)]
			
	
	var processed_result = ""
	for result in result_dict.values():
		processed_result += result
		
	blackboard_data_label.text = "[code]%s[/code]" % processed_result


func set_event_log_item(event_log: ReactionEventExecutionLogItem) -> void:
	event_label_edit.text = event_log.event_triggered.label
	event_uid_edit.text = event_log.event_triggered.uid
	
	rule_label_edit.text =  event_log.rule_triggered.label
	rule_uid_edit.text =  event_log.rule_triggered.uid
	
	_update_criterias(event_log.rule_triggered.criterias)
	_update_modifications(event_log.rule_triggered.modifications)
	
	_update_blackboard_data(event_log.old_blackboard, event_log.new_blackboard)
	event_log_data_container.visible = true
	
	
func _on_event_log_item_list_item_selected(index):
	var log_item = event_log_list.get_item_metadata(index)
	set_event_log_item(log_item)


func _on_close_requested() -> void:
	visible = false
