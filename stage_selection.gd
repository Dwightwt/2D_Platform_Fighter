##Code for selecting a stage

extends Control

@onready var musicAudioStreamBG = $AudioStreamPlayerBGmusic3
var backgroundsMusicOn = true

func _process(delta):
	update_music_stats()

func update_music_stats():
	if backgroundsMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/Stage 1/Stage1.tscn")



func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/Stage 2/Stage2.tscn")



func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Playscreen/playscreen.tscn")
