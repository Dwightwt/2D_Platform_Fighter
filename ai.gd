## The is for the enemy to detect the player and attack accordingly. 

extends Node2D
var enemy_scene = preload("res://scenes/SonicAI.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered:", body)
	var enemy = get_parent()
	var enemy_id = enemy.id
		
	if body.is_in_group("Player"):
		Input.action_press("attack_%s" % enemy.id)
		Input.action_release("attack_%s" % enemy.id)  
	pass
