@tool
extends MarginContainer

var current_database: ReactionDatabase
var current_rule: ReactionRuleItem

@onready var criteria_scene = preload("res://addons/reaction/components/criteria.tscn")
@onready var criterias_rows : HBoxContainer = %CriteriasRows


func _ready():
	pass # Replace with function body.


func setup_criterias(database: ReactionDatabase, rule: ReactionRuleItem) -> void:
	current_database = database
	current_rule = rule
	
	var index = 0
	for criteria in current_rule.criterias:
		var new_criteria_object = criteria_scene.instantiate()
		new_criteria_object.setup(criteria, index)
		criterias_rows.add_child(new_criteria_object)
		index += 1
