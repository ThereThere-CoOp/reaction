@tool
class_name ReactionFactUsageLog
extends Resource


@export var uid: String

@export var reference_object_label: String

@export var reference_object_type: String

@export_enum("Criteria", "Modification", "Tag") var  reference_type: String

@export var related_object: Resource
