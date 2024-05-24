@tool
extends VBoxContainer

var current_database: ReactionDatabase

var current_event: ReactionEventItem

var current_rule: ReactionRuleItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

@onready var rules_list: VBoxContainer = %RulesList
@onready var rule_data_container: TabContainer = %RuleDataContainer

# rules inputs
@onready var rule_name_input: LineEdit = %RuleNameLineEdit
@onready var rule_uid_input: LineEdit = %RuleUidLineEdit

@onready var rule_match_once_button: CheckButton = %RuleMatchOnceCheckButton
@onready var rule_priority_input: SpinBox = %RulePrioritySpinBox
@onready var rule_priority_text_edit: LineEdit = rule_priority_input.get_line_edit()

func _ready() -> void:
	rule_data_container.visible = false
	rule_priority_text_edit.connect("text_submitted", _on_rule_priority_spin_box_text_submitted)


func setup_rules(database: ReactionDatabase, current_event: ReactionEventItem) -> void:
	current_database = database
	rules_list.setup_items(current_database, current_event)


func _set_rule(rule_data: ReactionRuleItem) -> void:
	current_rule = rule_data
	# set input default values
	# general
	rule_name_input.text = rule_data.label
	rule_uid_input.text = rule_data.uid
	rule_match_once_button.button_pressed = rule_data.match_once
	rule_priority_input.set_value_no_signal(rule_data.priority)

	rule_data_container.visible = true


func _set_rule_property(property_name: StringName, value: Variant) -> void:
	current_rule.set(property_name, value)
	current_database.save_data()


## signals


func _on_rules_list_item_selected(item_data: ReactionRuleItem) -> void:
	_set_rule(item_data)


func _on_rule_name_input_line_edit_text_submitted(new_text: String) -> void:
	_set_rule_property("label", new_text)
	rules_list.items_list.set_item_text(rules_list.current_item_index, new_text)


func _on_rules_list_item_added(index: int, item_data: ReactionRuleItem):
	_set_rule(item_data)


func _on_rules_list_item_removed(index: int, item_data: ReactionRuleItem):
	if current_event.rules.size() > 0:
		_set_rule(rules_list.current_item)
	else:
		rule_data_container.visible = false


func _on_rule_match_once_check_button_pressed():
	_set_rule_property("match_once", not current_rule.match_once) # Replace with function body.


func _on_rule_priority_spin_box_text_submitted(new_text: String):
	_set_rule_property("priority", float(new_text))
	rule_priority_text_edit.release_focus()
