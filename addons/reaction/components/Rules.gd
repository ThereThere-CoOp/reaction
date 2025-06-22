@tool
extends VBoxContainer

var current_event: ReactionEventItem

var current_rule: ReactionRuleItem = null

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

var _sqlite_database: SQLite

@onready var rules_list: ReactionUIItemList = %RulesList
@onready var rule_data_container: TabContainer = %RuleDataContainer
@onready var criterias_container: ReactionUIListObjectForm = %Criterias
@onready var modifications_container: ReactionUIListObjectForm = %Modifications
@onready var responses_container: Responses = %Responses

# rules inputs
@onready var rule_name_input: LineEdit = %RuleNameLineEdit
@onready var rule_uid_input: LineEdit = %RuleUidLineEdit

@onready var rule_match_once_button: CheckButton = %RuleMatchOnceCheckButton
@onready var rule_priority_input: SpinBox = %RulePrioritySpinBox
@onready var rule_priority_text_edit: LineEdit = rule_priority_input.get_line_edit()



func _ready() -> void:
	rule_data_container.visible = false
	
	ReactionSignals.database_selected.connect(_on_database_selected)
	rule_priority_text_edit.text_submitted.connect(_on_rule_priority_spin_box_text_submitted)


func setup_rules(current_event: ReactionEventItem) -> void:
	rules_list.setup_items(current_event)


func _update_criterias_container_name() -> void:
	criterias_container.name = "Criterias (%d)" % current_rule.criterias.size()

	
func _update_modifications_container_name() -> void:
	modifications_container.name = "Modifications (%d)" % current_rule.modifications.size()
	
	
func _set_rule(rule_data: ReactionRuleItem) -> void:
	current_rule = rule_data
	# set input default values
	# general
	rule_name_input.text = rule_data.label
	rule_uid_input.text = rule_data.uid
	rule_match_once_button.button_pressed = rule_data.match_once
	rule_priority_input.set_value_no_signal(rule_data.priority)
	
	#criterias
	_update_criterias_container_name()
	criterias_container.setup_objects(current_rule)
	if not criterias_container.object_added.is_connected(_on_criteria_added):
		criterias_container.object_added.connect(_on_criteria_added)
		
	if not criterias_container.object_removed.is_connected(_on_criteria_removed):
		criterias_container.object_removed.connect(_on_criteria_removed)
	
	# modifications
	_update_modifications_container_name()
	modifications_container.setup_objects(current_rule)
	
	if not modifications_container.object_added.is_connected(_on_modification_added):
		modifications_container.object_added.connect(_on_modification_added)
		
	if not modifications_container.object_removed.is_connected(_on_modification_removed):
		modifications_container.object_removed.connect(_on_modification_removed)
	
	# responses
	var responses : ReactionResponseGroupItem = null
	if current_rule.response_group != null:
		responses = current_rule.response_group
	else: 
		responses = ReactionResponseGroupItem.get_new_object()
		responses.label = "rootResponseGroup"
		current_rule.response_group = responses
	
	responses_container.setup(responses)
	
	
	# show container
	rule_data_container.current_tab = 0
	rule_data_container.visible = true


func _set_rule_property(property_name: StringName, value: Variant) -> void:
	current_rule.set(property_name, value)
	current_rule.update_sqlite()
	
	
func _sort_rules_item_list() -> void:
	current_event.set("rules", current_event.rules.duplicate())
	rules_list.setup_items(current_event)


## signals


func _on_database_selected() -> void:
	_sqlite_database = ReactionGlobals.current_sqlite_database


func _on_rules_list_item_selected(item_data: ReactionRuleItem) -> void:
	_set_rule(item_data)


func _on_rule_name_input_line_edit_text_submitted(new_text: String) -> void:
	_set_rule_property("label", new_text)
	rules_list.items_list.set_item_text(rules_list.current_item_index, new_text)


func _on_rules_list_item_added(index: int, item_data: ReactionRuleItem):
	_set_rule(item_data)


func _on_rules_list_item_removed(index: int, item_data: ReactionRuleItem):
	if false: #current_event.rules.size() > 0:
		#_set_rule(rules_list.current_item)
		pass
	else:
		rule_data_container.visible = false


func _on_rule_match_once_check_button_pressed():
	_set_rule_property("match_once", not current_rule.match_once) # Replace with function body.


func _on_rule_priority_spin_box_text_submitted(new_text: String):
	_set_rule_property("priority", float(new_text))
	rule_priority_text_edit.release_focus()
	_sort_rules_item_list()
	
	
func _on_criteria_added(new_criteria: ReactionCriteriaItem) -> void:
	_update_criterias_container_name()
	_sort_rules_item_list()
	
	
func _on_criteria_removed() -> void:
	_update_criterias_container_name()
	_sort_rules_item_list()
	

func _on_modification_added(new_criteria: ReactionContextModificationItem) -> void:
	_update_modifications_container_name()
	
	
func _on_modification_removed() -> void:
	_update_modifications_container_name()
	
