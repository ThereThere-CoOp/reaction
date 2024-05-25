@tool
extends MarginContainer

var current_databaase: ReactionDatabase
var current_rule: ReactionRuleItem

@onready var criteria_scene = preload("res://addons/reaction/components/criteria.tscn")
@onready var criterias_rows : HBoxContainer = %CriteriasRows


func _ready():
	pass # Replace with function body.


func setup_criterias(databaase: ReactionDatabase, rule: ReactionRuleItem) -> void:
	current_databaase = databaase
	current_rule = rule
	
	for criteria in current_rule.criterias:
		var new_criteria_object = criteria_scene.instantiate()
		
