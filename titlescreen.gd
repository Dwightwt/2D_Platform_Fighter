//Handles scene transition from title screen to options menu or to playscreen screen. Otherwise pressing exit. This also plays music

extends Control

@onready var musicAudioStreamBG = $"AudioStreamPlayer-BGmusic"
var backgroundsMusicOn = true

func _process(delta):
	update_music_stats()

func update_music_stats():
	if backgroundsMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Playscreen/playscreen.tscn")


func _on_options_pressed() -> void:
	print("Options pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
