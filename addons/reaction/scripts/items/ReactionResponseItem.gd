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


## Event that this response triggers
@export var triggers: ReactionEventItem
