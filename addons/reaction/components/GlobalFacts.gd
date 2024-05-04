@tool
extends MarginContainer

var current_database: ReactionDatabase

var selected_item_index: int = -1

var undo_redo: EditorUndoRedoManager:
	set(next_undo_redo):
		undo_redo = next_undo_redo
	get:
		return undo_redo

@onready var facts_list: ItemList = %FactsList
@onready var fact_data_container: VBoxContainer = %FactDataContainer
@onready var remove_fact_button: Button = %RemoveFactButton

# fact inputs
@onready var fact_uid_value_label: LineEdit = %FactUidValue


func _ready() -> void:
	if not facts_list.is_anything_selected():
		remove_fact_button.disabled = true
		fact_data_container.visible = false


func setup_facts(database: ReactionDatabase) -> void:
	facts_list.clear()
	remove_fact_button.disabled = true
	fact_data_container.visible = false

	current_database = database
	for fact in current_database.global_facts.values():
		var index = facts_list.add_item(fact.label)
		facts_list.set_item_metadata(index, fact)


func _add_fact(fact: ReactionFactItem) -> void:
	current_database.add_fact(fact)
	var index = facts_list.add_item(fact.label)
	facts_list.set_item_metadata(index, fact)
	_set_fact(index)


func _remove_fact(data: Dictionary) -> void:
	current_database.remove_fact(data["fact"].uid)
	facts_list.remove_item(data["index"])

	if current_database.global_facts.size() > 0:
		_set_fact(0)
	else:
		selected_item_index = -1
		remove_fact_button.disabled = true
		fact_data_container.visible = false
		facts_list.deselect_all()

func _set_fact(index: int) -> void:
	var current_fact = facts_list.get_item_metadata(index)
	selected_item_index = index
	facts_list.select(index)

	# set input default values
	fact_uid_value_label.text = current_fact.uid

	remove_fact_button.disabled = false
	fact_data_container.visible = true


### signals


func _on_add_fact_button_pressed() -> void:
	var new_fact = ReactionFactItem.new()

	undo_redo.create_action("Add fact")
	undo_redo.add_do_method(self, "_add_fact", new_fact)
	undo_redo.add_undo_method(
		self, "_remove_fact", {"fact": new_fact, "index": current_database.global_facts.size()}
	)
	undo_redo.commit_action()


func _on_remove_fact_button_pressed() -> void:
	undo_redo.create_action("Remove fact")
	undo_redo.add_do_method(
		self,
		"_remove_fact",
		{"fact": facts_list.get_item_metadata(selected_item_index), "index": selected_item_index}
	)
	undo_redo.add_undo_method(self, "_add_fact", facts_list.get_item_metadata(selected_item_index))
	undo_redo.commit_action()


func _on_facts_list_item_selected(index: int) -> void:
	_set_fact(index)
