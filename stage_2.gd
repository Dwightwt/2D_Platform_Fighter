##Stage 1 code that includes music and pause menu.

extends Node2D

@onready var pause_menu2 = $Pausemenu2
var paused = false

@onready var musicAudioStreamBG = $AudioStreamPlayerBGmusic5
var backgroundsMusicOn = true

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu2()
	update_music_stats()

func update_music_stats():
	if backgroundsMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()
func pauseMenu2():
	if paused:
		pause_menu2.hide()
		Engine.time_scale = 1
	else:
		pause_menu2.show()
		Engine.time_scale = 0
	
	paused = !paused
