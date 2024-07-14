@tool
extends Control


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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func add_event_log(new_event_log) -> void:
	pass


