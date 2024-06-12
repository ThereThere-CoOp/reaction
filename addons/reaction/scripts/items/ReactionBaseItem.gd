@tool
class_name ReactionBaseItem
extends Resource
## ----------------------------------------------------------------------------[br]
## Base parent resource class for reaction items.
##
## A base class for reaction items like facts, rules, concepts and responses.
## Contains common fields and functions for reaction items. [br]
## ----------------------------------------------------------------------------

@export_group("Item general data")
@export var uid: String = Uuid.v4()

@export var label: String = "item_label"
@export var description: String = "Item long description"

@export_enum("Global", "Event") var scope: String = "Global"

@export_group("")
