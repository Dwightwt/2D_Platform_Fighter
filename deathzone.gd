## Death areas for characters to despawn once the player collides

extends Area2D

var respawn_manger
var sonic

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	respawn_manger = get_parent().get_node("RespawnManger")
	sonic = get_parent().get_node("Sonic")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Sonic"):
		killPlayer()

func killPlayer():
	sonic.position = respawn_manger.last_location
