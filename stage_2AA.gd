##Code for challenge mode stage 2, spawns more enemies if the current amount is less than the max, handles score calculation, and removes defeated enemy.

extends Node2D

var enemy_scene = preload("res://scenes/SonicAI.tscn")
var hitbox_scene = preload("res://Hitbox/Hitbox.tscn")
var h = hitbox_scene.instantiate()
var enemy = enemy_scene.instantiate()
@export var max_enemies = 2  # Maximum number of enemies allowed at one time
var active_enemies = []  # List to keep track of active enemies
var enemy_id_counter = 0
var total_score = 0
var current_score = 0
var calculated_score = 0
func _on_timer_timeout():
	if active_enemies.size() - 1 < max_enemies:
		print(active_enemies.size())
		var enemy = enemy_scene.instantiate()
		enemy.id = enemy_id_counter
		enemy_id_counter += 5 
		enemy.position = Vector2(randi_range(128, 1664), -256)
		add_child(enemy)
		active_enemies.append(enemy)
		enemy.connect("tree_exited", Callable(self, "_on_enemy_removed").bind(enemy))
		

func update_score_label():
	calculated_score = 0
	for enemy in active_enemies:
		calculated_score += enemy.percentage
	return calculated_score

func _physics_process(delta):
	calculated_score = update_score_label()
	if total_score < calculated_score:
		total_score = calculated_score
	$Sonic/Score.text = "Score: %d" % total_score
	
func _on_enemy_removed(enemy):
	active_enemies.erase(enemy)
