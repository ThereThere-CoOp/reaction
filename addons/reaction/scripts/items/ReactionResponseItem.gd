@tool
class_name ReactionResponseItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Reource class to storage and manage a reaction response.
##
## An a response could returns several things: a npc text,
## sound effect, an action that alter world state, a script etc and
## trigger also other concept or event. [br]
## ----------------------------------------------------------------------------


## Uuid of the event that this response triggers
@export var triggers: String


func get_type_string() -> int:
	return ReactionGlobals.ItemsTypesEnum.RESPONSE
