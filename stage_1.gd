##Stage 1 code that includes music and pause menu.

extends Node2D

@onready var pause_menu = $PauseMenu

@onready var musicAudioStreamBG = $AudioStreamPlayerBGmusic4
var backgroundsMusicOn = true



var paused = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
		
	update_music_stats()

func update_music_stats():
	if backgroundsMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
