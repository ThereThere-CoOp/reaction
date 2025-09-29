@tool
class_name ReactionResponseDialogItem
extends ReactionResponseItem
## ----------------------------------------------------------------------------[br]
## A resource item to store a Reaction dialog response.
##
## A dialog response consist of a dialog text and optionally
## could contains options. [br]
## ----------------------------------------------------------------------------

## text line of the dialog
@export var texts: Array[ReactionDialogTextItem] :
	set(value):
		var rules: Array[ReactionRuleItem]
		rules.assign(value)
		
		var order_result: Array[ReactionDialogTextItem]
		order_result.assign(ReactionGlobals.sort_rules(rules))
		texts = order_result
		
		if Engine.is_editor_hint():
			notify_property_list_changed()

## true if the dialog have choices
@export var have_choices: bool = false

## list of [ReactionDialogChoices] if [b]have_choice=true[/b]
@export var choices: Array[ReactionDialogChoiceItem]


func _init() -> void:
	super()
	
	
## ----------------------------------------------------------------------------[br]
## Return the array of choices that met their criterias by the current context
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if choice
## match with facts data [br]
## [b]Returns: Array[ReactionDialogChoice][/b] [br]
## Returns array of choices that met their criterias by the current context  [br]
## ----------------------------------------------------------------------------
func get_choices(context: ReactionBlackboard) -> Array[ReactionDialogChoiceItem]:
	var result_choices: Array[ReactionDialogChoiceItem] = []
	if have_choices:
		for choice in choices:
			if choice.test(context):
				result_choices.append(choice)
			
	return result_choices
	

func get_choice_by_uid(uid: String) -> ReactionDialogChoiceItem:
	for choice in self.choices:
		if choice.uid == uid:
			return choice
			
	return null
	
	
## ----------------------------------------------------------------------------[br]
## Add a new choice to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* None[/b] [br]
## [b]Returns: ReactionDialogChoice[/b] [br]
## The new added dialog choice  [br]
## ----------------------------------------------------------------------------
func add_new_choice() -> ReactionDialogChoiceItem:
	var new_dialog_choice = ReactionDialogChoiceItem.new()
	new_dialog_choice.label = "newDialogChoice"
	choices.append(new_dialog_choice)
			
	return new_dialog_choice
	
	
## ----------------------------------------------------------------------------[br]
## Add a choice to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* choice | ReactionDialogChoice:[/b] Choice to be added
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_choice(choice: ReactionDialogChoiceItem) -> void:
	choices.append(choice)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a choice from the response given an index of the choices array
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the choice to remove
## [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_choice_by_index(index: int) -> void:
	choices.remove_at(index)
	
	
## ----------------------------------------------------------------------------[br]
## Return the first text that met their criterias by the current context
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* context | [ReactionBlackboard]:[/b] Blackboard context to check if choice
## match with facts data [br]
## [b]Returns: ReactionDialogTextItem[/b] [br]
## Returns the first text that met their criterias by the current context  [br]
## ----------------------------------------------------------------------------
func get_text(context: ReactionBlackboard) -> ReactionDialogTextItem:
	var result_choices = []
	for text in texts:
		if text.test(context):
			return text
			
	return null
	
	
func get_text_by_uid(uid: String) -> ReactionDialogTextItem:
	for text in self.texts:
		if text.uid == uid:
			return text
			
	return null
	
	
## ----------------------------------------------------------------------------[br]
## Add a new text to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* None[/b] [br]
## [b]Returns: ReactionDialogTextItem[/b] [br]
## The new added dialog text  [br]
## ----------------------------------------------------------------------------
func add_new_text() -> ReactionDialogTextItem:
	var new_dialog_text = ReactionDialogTextItem.new()
	new_dialog_text.label = "newDialogText"
	texts.append(new_dialog_text)
			
	return new_dialog_text
	
	
## ----------------------------------------------------------------------------[br]
## Add a text to the dialog response
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* text | ReactionDialogTextItem:[/b] Choice to be added
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func add_text(text: ReactionDialogTextItem) -> void:
	texts.append(text)
	
	
## ----------------------------------------------------------------------------[br]
## Remove a text from the response given an index of the choices array
## [br]
## [b]Parameter(s):[/b] [br]
## [b]* index | int:[/b] Index of the choice to remove
## [br]
## [b]Returns: void[/b] [br]
## ----------------------------------------------------------------------------
func remove_text_by_index(index: int) -> void:
	texts.remove_at(index)
	
	
func export():
	var text_object: ReactionDialogTextItem = ReactionDialogTextItem.new()
	text_object.parent_item = self
	
	var text_list: Array[ReactionDialogTextItem]
	text_list.assign(text_object.get_sqlite_list(null, true))
	
	for text in text_list:
		text.export()
		
	texts = text_list
	
	if have_choices:
		var choice_object: ReactionDialogChoiceItem = ReactionDialogChoiceItem.new()
		choice_object.parent_item = self
	
		var choice_list: Array[ReactionDialogChoiceItem]
		choice_list.assign(choice_object.get_sqlite_list(null, true))
		
		for choice in choice_list:
			choice.export()
			
		choices = choice_list
		
	
func remove_from_sqlite() -> bool:
	var dialog_text_file_paths: Array[String] = []
		
	var where = "response_id = %d" % [sqlite_id]
	var dialog_choices = _sqlite_database.select_rows("rule", where, ['file_path'])
	
	for text_data in dialog_choices:
		var file_path = text_data.get("file_path", {})
		file_path = JSON.parse_string(file_path)
		dialog_text_file_paths.append_array(file_path.values())
		
	var success = super()
	
	ReactionSignals.dialog_text_removed.emit(dialog_text_file_paths)
	return success 
	
	
static func get_new_object():
	return ReactionResponseDialogItem.new()
	
	
func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.DIALOG
