//Pause menu for stage 2

extends Control

@onready var Stage2 = $".."


func _on_resume_pressed() -> void:
	Stage2.pauseMenu2()



func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/StageSelection/stage_selection.tscn")
