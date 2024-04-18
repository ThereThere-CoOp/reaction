@tool
class_name ReactionResponseGroupItem
extends ReactionResponseBaseItem
## ----------------------------------------------------------------------------[br]
## Class item to storage and manage a response group.
##
## A response group have at least one response a [ReactionResponseItem] and
## manage the behavior of the responses within it.
## ----------------------------------------------------------------------------


## list of responses or responses groups
@export var responses: Array[ReactionResponseBaseItem] = []


func get_responses():
    return responses