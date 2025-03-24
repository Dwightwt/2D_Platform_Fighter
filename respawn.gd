//respawner for player character

extends Area2D

var respawn_manger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	respawn_manger = get_parent().get_parent().get_node("RespawnManger")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Sonic"):
		respawn_manger.last_location = $RespawnPoint.global_position
