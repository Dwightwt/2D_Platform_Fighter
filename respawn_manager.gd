//Respawn manager

extends Node

var last_location
var sonic

func _ready() -> void:
	sonic = get_parent().get_node("Sonic")
	last_location = sonic.global_position
