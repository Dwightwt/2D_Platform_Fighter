##Code for Sonic including all of his stats and physics attributes, attack data, hitboxes, sqllite data retrieval, and hitpause.

extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var id: int

var frame = 0

#database variable
var database : SQLite

#Ground Variables
var dash_duration = 10

#Attribute Variables
@export var percentage = 0
@export var stocks = 3
@export var weight = 100
var freezeframes = 0

#Knockback Variables
var h_decay
var v_decay
var knockback
var hitstun
var connected : bool

#Landing Variables
var landing_frames = 0
var lag_frames = 0
#Buffers
var l_cancel = 0
var cooldown = 0
#Air Variables
var jump_squat = 3
var airJump = 0
var fastfall = false
@export var airJumpMax = 1


#Sonic Main attributes
var RUNSPEED
var DASHSPEED
var WALKSPEED
var GRAVITY
var JUMPFORCE
var MAXJUMPFORCE
var DOUBLEJUMPFORCE
var MAXAIRSPEED
var AIR_ACCEL
var FALLSPEED
var FALLINGSPEED 
var MAXFALLSPEED 
var TRACTION
#var ROLL_DISTANCE = 350 * 2
#var air_dodge_speed = 500 * 2
#var UP_B_LAUNCHSPEED = 700 * 2

@export var hitbox: PackedScene
var selfState

#Temporary Variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)

#Onready Variables

@onready var GroundL = get_node('Raycasts/GroundL')
@onready var GroundR = get_node('Raycasts/GroundR')
@onready var Ledge_Grab_F = get_node("Raycasts/Ledge_Grab_F")
@onready var Ledge_Grab_B = get_node("Raycasts/Ledge_Grab_B")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var states = $State
@onready var anim: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
#Globals Variables

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag = 1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	#Rotates the points
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, -angle + 180, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
	return hitbox_instance

func updateframes(delta):
	frame += floor(delta * 60)
	l_cancel -= floor(delta * 60)
	clampi(l_cancel, 0, l_cancel)
	cooldown -= floor(delta * 60)
	cooldown = clampi(cooldown, 0, cooldown)
	if freezeframes > 0:
		freezeframes -= floor(delta * 60)
	freezeframes = clampi(freezeframes, 0, freezeframes)

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:	
		dir = 1
	$AnimatedSprite2D.set_flip_h(direction)
	Ledge_Grab_F.set_target_position(Vector2(dir*abs(Ledge_Grab_F.get_target_position().x), Ledge_Grab_F.get_target_position().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_target_position(Vector2(-dir*abs(Ledge_Grab_F.get_target_position().x), Ledge_Grab_F.get_target_position().y))


func play_animation(animation_name):
	anim.play(animation_name)

func direction():
	if Ledge_Grab_F.get_target_position().x > 0:
		return 1
	else:
		return -1

func _frame():
	frame = 0
	
func _ready():
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	
	var tables = {
		"character" : {
			"character_id" : {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
			"name" : {"data_type": "text"},
			"runspeed" : {"data_type" : "int"},
			"dashspeed" : {"data_type" : "int"},
			"walkspeed" : {"data_type" : "int"},
			"gravity" : {"data_type" : "int"},
			"jumpforce" : {"data_type" : "int"},
			"maxjumpforce" : {"data_type" : "int"},
			"doublejumpforce" : {"data_type" : "int"},
			"maxairspeed" : {"data_type" : "int"},
			"airaccel" : {"data_type" : "int"},
			"fallspeed" : {"data_type" : "int"},
			"fallingspeed" : {"data_type" : "int"},
			"maxfallspeed" : {"data_type" : "int"},
			"traction" : {"data_type" : "int"}
		},
		
		
		"user": {
			"user_id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
			"username": {"data_type": "text"},
			"email": {"data_type": "text"},
			"password_hash": {"data_type": "text"}
	},
	
	
		"statistic": {
			"stat_id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
			"user_id": {"data_type": "int", "foreign_key": "User.User_ID"},
			"character_id": {"data_type": "int", "foreign_key": "Characters.character_id"},
			"total_victories": {"data_type": "int"},
			"total_losses": {"data_type": "int"},
			"times_used": {"data_type": "int"}
		}
	}
	for table_name in tables:
		database.create_table(table_name, tables[table_name])
	var result = database.select_rows("character", "name = 'Sonic'", ["*"])
	var row = result[0]
	RUNSPEED = row.get("runspeed") * 2
	DASHSPEED = row.get("dashspeed") * 2
	WALKSPEED = row.get("walkspeed") * 2
	GRAVITY = row.get("gravity")
	JUMPFORCE = row.get("jumpforce")
	MAXJUMPFORCE = row.get("maxjumpforce")
	DOUBLEJUMPFORCE = row.get("doublejumpforce")
	MAXAIRSPEED = row.get("maxairspeed")
	AIR_ACCEL = row.get("airaccel")
	FALLSPEED = row.get("fallspeed")
	FALLINGSPEED = row.get("fallingspeed")
	MAXFALLSPEED = row.get("maxfallspeed")
	TRACTION = row.get("traction")
	pass

func reset_Jumps():
	airJump = airJumpMax

func _physics_process(delta):
	
	$Frames.text = str(frame)
	$Percentage.text = str(percentage)
	selfState = states.text

func _hit_pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector2(0,0):
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector2(0,0)
		hit_pause_dur = 0
		hit_pause = 0

#Air Attacks

func NAIR():
	if frame == 4:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 2, 1)
	if frame == 6:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 2, 1)
	if frame == 9:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 2, 1)
	if frame == 12:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 2, 1)
	if frame == 15:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 2, 1)
	if frame == 18:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 1, 1)
	if frame == 21:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 1, 1)
	if frame == 24:
		create_hitbox(28, 28, 2, 290, 140, 100, 3, 'normal', Vector2(0,1), 1, 1)
	if frame == 27:
		create_hitbox(28, 28, 2, 45, 140, 100, 3, 'normal', Vector2(0,1), 0, 1)
	if frame == 30:
		return true

func UAIR():
	if frame == 12:
		create_hitbox(16, 28, 7, 70, 2, 90, 5, 'normal', Vector2(11,-4), 0, 2)
	if frame >= 21:
		return true

func DAIR():
	if frame == 13:
		create_hitbox(20, 12, 7, -90, 3, 120, 5, 'normal', Vector2(12,10), 0, 2)
	if frame >= 27:
		return true

func BAIR():
	if frame == 12:
		create_hitbox(20, 14, 7, 45, 3, 120, 5, 'normal', Vector2(-9,-2), 6, 1)
	if frame >= 23:
		return true

func FAIR():
	if frame < 17:
		self.velocity.x = 0
	if frame == 17:
		if direction() == 1:
			self.velocity.x = 800
		else:
			self.velocity.x = -800
		create_hitbox(48, 16, 4, 45, 2, 45, 17, 'normal', Vector2(0,5), 0, 1)
	if frame >= 17:
		self.velocity.y = 0
	if frame >= 45:
		return true

#Tilt Attacks
func DOWN_TILT():
	if frame == 6:
		create_hitbox(20, 12, 7, 85, 1, 60, 5, 'normal', Vector2(12,10), 0, 1)
	if frame >= 27:
		return true

func UP_TILT():
	if frame == 7:
		create_hitbox(14, 32, 4, 90, 3, 120, 9, 'normal', Vector2(11,1), 0, 1)
	if frame >= 19:
		return true
		

func FORWARD_TILT():
	if frame == 9:
		create_hitbox(20, 12, 6, 10, 3, 120, 6, 'normal', Vector2(12,1), 0, 1)
	if frame >= 27:
		return true
		

func JAB():
	if frame == 5:
		create_hitbox(18, 12, 5, 20, 3, 90, 8, 'normal', Vector2(12,0), 0, 1)
	if frame >= 19:
		return true
