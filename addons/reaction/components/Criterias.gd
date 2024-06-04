@tool
extends MarginContainer

var current_database: ReactionDatabase
var current_rule: ReactionRuleItem

@onready var criteria_scene = preload("res://addons/reaction/components/criteria.tscn")
@onready var criterias_rows : VBoxContainer = %CriteriasRows
@onready var criterias_scroll_container : ScrollContainer = %CriteriasScrollContainer
@onready var _criterias_scrollbar: VScrollBar = criterias_scroll_container.get_v_scroll_bar()

var _criterias_scroll_to_end = false

func _ready():
	ReactionSignals.database_selected.connect(_on_database_selected)
	_criterias_scrollbar.changed.connect(_on_criterias_scroll_changed)


func setup_criterias(rule: ReactionRuleItem) -> void:
	current_rule = rule
	
	for criteria in criterias_rows.get_children():
		criteria.queue_free()
	
	_criterias_scroll_to_end = false
	var index = 0
	for criteria in current_rule.criterias:
		var new_criteria_object = criteria_scene.instantiate()
		new_criteria_object.setup(current_database, current_rule, criteria, index)
		criterias_rows.add_child(new_criteria_object)
		index += 1


### signals


func _on_database_selected(database: ReactionDatabase) -> void:
	current_database = database


func _on_add_criteria_button_pressed():
	var reaction_criteria = ReactionRuleCriteria.new()
	reaction_criteria.label = "newCriteria"
	current_rule.add_criteria(reaction_criteria)
	current_database.save_data()
	var index = current_rule.criterias.size() - 1
	var new_criteria_object = criteria_scene.instantiate()
	new_criteria_object.setup(current_database, current_rule, reaction_criteria, index, true)
	_criterias_scroll_to_end = true
	criterias_rows.add_child(new_criteria_object)
	
	
func _on_criterias_scroll_changed() -> void:
	if _criterias_scroll_to_end:
		criterias_scroll_container.set_v_scroll(int(_criterias_scrollbar.max_value))
