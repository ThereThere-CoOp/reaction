@tool
extends VBoxContainer


var current_database: ReactionDatabase

var current_rule: ReactionRuleItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo


@onready var rules_list: VBoxContainer = %RulesList
@onready var rule_data_container: VBoxContainer = %RuleDataContainer

# event inputs
@onready var rule_name_input: LineEdit = %RuleNameLineEdit
@onready var rule_uid_input: LineEdit = %RuleUidLineEdit


func _ready() -> void:
	rule_data_container.visible = false
	
	
func setup_rules(database: ReactionDatabase, current_event: ReactionEventItem) -> void:
	current_database = database
	rules_list.setup_items(current_database, current_event)
	
	
func _set_rule(rule_data: ReactionRuleItem) -> void:
	current_rule = rule_data
	# set input default values
	rule_name_input.text = rule_data.label
	rule_uid_input.text = rule_data.uid
	
	rule_data_container.visible = true


func _set_rule_property(property_name: StringName, value: Variant) -> void:
	current_rule.set(property_name, value)
	current_database.save_data()
