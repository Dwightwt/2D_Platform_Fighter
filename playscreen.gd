##Code for the playscreen to choose versus mode or challenge mode

extends Control

@onready var musicAudioStreamBG = $AudioStreamPlayerBGmusic2
var backgroundsMusicOn = true

func _process(delta):
	update_music_stats()

func update_music_stats():
	if backgroundsMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()


func _on_smash_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/StageSelection/stage_selection.tscn")


func _on_challenges_pressed() -> void:
	print("Challenges pressed")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Titlescreen/titlescreen.tscn")
