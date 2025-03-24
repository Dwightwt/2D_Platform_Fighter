##Pause menu for stage 1

extends Control

@onready var Stage1 = $".."


func _on_resume_pressed() -> void:
	Stage1.pauseMenu()



func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/StageSelection/stage_selection.tscn")
