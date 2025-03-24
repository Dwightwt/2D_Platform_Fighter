##State Machine for the character "Sonic", this includes his attacks and inputs, and all his states. Also ensures states transition smoothly from one to another.

extends StateMachine
@onready var id = get_parent().id


func _ready():
	# Adding all the states
	add_state('STAND')
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('WALK')
	add_state('MOONWALK')
	add_state('CROUCH')
	add_state('AIR')
	add_state('LANDING')
	add_state('HITFREEZE')
	add_state('HITSTUN')
	add_state('TURN')
	add_state('RUN')
	add_state('GROUND_ATTACK')
	add_state('DOWN_TILT')
	add_state('UP_TILT')
	add_state('FORWARD_TILT')
	add_state('JAB')
	add_state('AIR_ATTACK')
	add_state('NAIR')
	add_state('DAIR')
	add_state('UAIR')
	add_state('FAIR')
	add_state('BAIR')


	# Setting initial state to STAND
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	# Update the parent's frames and physics each frame
	parent.updateframes(delta)
	parent._physics_process(delta)
	parent._hit_pause(delta)

func get_transition(delta):
	parent.set_velocity(parent.velocity)
	# Set character's up direction and handle movement
	parent.set_up_direction(Vector2.UP)
	parent.move_and_slide()
	parent.velocity
	
	if Landing() == true:
		parent._frame()
		return states.LANDING
	
	if Falling() == true:
		return states.AIR

	if Input.is_action_just_pressed("attack_%s" % id) && TILT() == true:
		parent._frame()
		return states.GROUND_ATTACK
	
	if Input.is_action_just_pressed("attack_%s" % id) && AIREAL():
		if Input.is_action_pressed("up_%s" % id):
			parent._frame()
			return states.UAIR
		if Input.is_action_pressed("down_%s" % id):
			parent._frame()
			return states.DAIR
		match parent.direction():
			1:
				if Input.is_action_pressed("left_%s" % id):
					parent._frame()
					return states.BAIR
				if Input.is_action_pressed("right_%s" % id):
					parent._frame()
					return states.FAIR
			-1:
				if Input.is_action_pressed("right_%s" % id):
					parent._frame()
					return states.BAIR
				if Input.is_action_pressed("left_%s" % id):
					parent._frame()
					return states.FAIR
		parent._frame()
		return states.NAIR
	
	match state:
		states.STAND:
			parent.reset_Jumps()
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.DASH

			# Apply traction if no input
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)

		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerpf(parent.velocity.x,0,0.08)
					parent._frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerpf(parent.velocity.x,0,0.08)
					parent._frame()
					return states.FULL_HOP

		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent._frame()
			return states.AIR

		states.FULL_HOP:
			parent.velocity.y = -parent.MAXJUMPFORCE
			parent._frame()
			return states.AIR

		states.DASH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			elif Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent._frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent._frame()
					return states.RUN
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent._frame()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration - 1:
					if Input.is_action_just_pressed("down_%s" % id):
						parent._frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent._frame()
					return states.RUN
			else:
				if parent.frame >= parent.dash_duration - 1:
					for state in states:
						if state != "JUMP_SQUAT":
								parent._frame()
								return states.STAND


		states.MOONWALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			
			elif Input.is_action_pressed("left_%s" % id) && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left_%s" % id)
				parent.velocity.x = clampf(parent.velocity.x, -parent.DASHSPEED, parent.velocity.x)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent._frame()
					return states.STAND
					
			elif Input.is_action_pressed("right_%s" % id) && parent.direction() == -1:
				if parent.velocity.x < 0:
					parent._frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right_%s" % id)
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, parent.DASHSPEED)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(true)
					return states.MOONWALK
				else:
					parent.turn(false)
					parent._frame()
					return states.STAND

		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.CROUCH
			if Input.is_action_just_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED * Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			if Input.get_action_strength("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED * Input.get_action_strength("right_%s" % id)
				parent.turn(false)  
			else:
				parent._frame()
				return states.STAND

		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent._frame()
				return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x > parent.RUNSPEED:
					parent.velocity.x -= (parent.TRACTION * 4)
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				else:
					parent.velocity.x += -(parent.TRACTION / 2)
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				if abs(parent.velocity.x) > parent.RUNSPEED:
					parent.velocity.x += (parent.TRACTION * 4)
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
				else:
					parent.velocity.x += (parent.TRACTION / 2)
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)


		states.AIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED


		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent._frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent._frame()
					return states.TURN
			elif Input.get_action_strength("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent._frame()
					return states.TURN
			else:
				parent._frame()
				return states.STAND


		states.LANDING:
			if parent.frame == 1:
				if parent.l_cancel >= 0:
					parent.lag_frames = floor(parent.lag_frames / 2)
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.velocity.x > 0:
					parent.velocity.x =  parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, 0 , parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x =  parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0 )
				if Input.is_action_just_pressed("jump_%s" % id):
					parent._frame()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent._frame()
					parent.reset_Jumps()
					return states.CROUCH
				else:
					parent._frame()
					parent.lag_frames = 0
					parent.reset_Jumps()
					return states.STAND
				parent.lag_frames = 0

		states.HITFREEZE:
			if parent.freezeframes == 0:
				parent._frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.h_decay = hd
				parent.v_decay = vd
				return states.HITSTUN
			parent.position = pos

		states.HITSTUN:
			if parent.knockback >= 0:
				var bounce = parent.move_and_collide(parent.velocity * delta)
#				if bounce:
#					parent.velocity = parent.velocity.bounce(bounce.get_normal()) * 0.8
#					parent.hitstun = round(parent.hitstun * 0.8)
				if parent.is_on_wall():
					parent.velocity.x = kbx - parent.velocity.x
					parent.velocity = parent.velocity.bounce(parent.get_wall_normal()) * .8
					parent.h_decay *= -1
					parent.hitstun = round(parent.hitstun * .8)
				if parent.is_on_floor():
					parent.velocity.y = kby - parent.velocity.y
					parent.velocity = parent.velocity.bounce(parent.get_floor_normal()) * .8
					parent.hitstun = round(parent.hitstun * .8)
			if parent.velocity.y < 0:
				parent.velocity.y += parent.v_decay * 0.5 * Engine.time_scale
				parent.velocity.y = clampf(parent.velocity.y, parent.velocity.y, 0)
			if parent.velocity.x < 0:
				parent.velocity.x += (parent.h_decay) * 0.4 * -1 * Engine.time_scale
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.h_decay * 0.4 * Engine.time_scale
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent._frame()
					return states.AIR
				else:
					parent._frame()
					return states.AIR
			elif parent.frame > 60 * 5:
				return states.AIR

		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent._frame()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x += -parent.TRACTION * 2
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION * 2
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent._frame()
					return states.STAND
				else:
					parent._frame()
					return states.RUN

		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s" % id):
				parent._frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s" % id):
						parent._frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent._frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("right_%s" % id):
						parent._frame()
						return states.BAIR
					if Input.is_action_pressed("left_%s" % id):
						parent._frame()
						return states.FAIR
			parent._frame()
			return states.NAIR

		states.NAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('nair')
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent._frame()
				return states.AIR

		states.DAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('dair')
				parent.DAIR()
			if parent.DAIR() == true:
				parent.lag_frames = 0
				parent._frame()
				return states.AIR

		states.UAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('uair')
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent._frame()
				return states.AIR

		states.BAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('bair')
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent._frame()
				return states.AIR

		states.FAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print("fair")
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 0
				parent._frame()
				return states.AIR
			

		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent._frame()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent._frame()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent._frame()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent._frame()
				return states.FORWARD_TILT
			parent._frame()
			return states.JAB

		states.DOWN_TILT:
			if parent.frame == 0:
				parent.DOWN_TILT()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if parent.DOWN_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent._frame()
					return states.CROUCH
				else:
					parent._frame()
					return states.STAND
		
		states.UP_TILT:
			if parent.frame == 0:
				parent._frame()
				parent.UP_TILT()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x = -parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if parent.UP_TILT() == true:
					parent._frame()
					return states.STAND
		
		states.FORWARD_TILT:
			if parent.frame == 0:
				parent._frame()
				parent.FORWARD_TILT()
			if parent.frame <= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION*2
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION*2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if parent.FORWARD_TILT() == true:
				if Input.is_action_pressed("left_%s" % id):
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
					parent._frame()
					return states.WALK
				if Input.is_action_pressed("right_%s" % id):
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION / 2
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
					parent._frame()
					return states.WALK
				else:
					parent._frame()
					return states.STAND


		states.JAB:
			if parent.frame == 0:
				parent.JAB()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if parent.JAB() == true:
				if Input.is_action_pressed("left_%s" % id):
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
					parent._frame()
					return states.DASH
				if Input.is_action_pressed("right_%s" % id):
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION / 2
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
					parent._frame()
					return states.DASH
				else:
					parent._frame()
					return states.STAND

func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('Idle')
			parent.states.text = str('STAND')
		states.DASH:
			parent.play_animation('Run')
			parent.states.text = str('DASH')
		states.MOONWALK:
			parent.play_animation('Walk')
			parent.states.text = str('MOONWALK')
		states.WALK:
			parent.play_animation('Walk')
			parent.states.text = str('WALK')
		states.TURN:
			parent.play_animation('Turn')
			parent.states.text = str('TURN')
		states.CROUCH:
			parent.play_animation('Crouch')
			parent.states.text = str('CROUCH')
		states.RUN:
			parent.play_animation('Run')
			parent.states.text = str('RUN')
		states.JUMP_SQUAT:
			parent.play_animation('Jump_Squat')
			parent.states.text = str('JUMP_SQUAT')
		states.SHORT_HOP:
			parent.play_animation('Air')
			parent.states.text = str('SHORT_HOP')
		states.FULL_HOP:
			parent.play_animation('Air')
			parent.states.text = str('FULL_HOP')
		states.AIR:
			parent.play_animation('Air')
			parent.states.text = str('AIR')
		states.LANDING:
			parent.play_animation('Landing')
			parent.states.text = str('LANDING')
		states.HITFREEZE:
			parent.play_animation('Hitstun')
			parent.states.text = str('HITFREEZE')
		states.HITSTUN:
			parent.play_animation('Hitstun')
			parent.states.text = str('HITSTUN')
		states.AIR_ATTACK:
			parent.states.text = str('AIR_ATTACK')
		states.NAIR:
			parent.play_animation('NAIR')
			parent.states.text = str('NAIR')
		states.DAIR:
			parent.play_animation('DAIR')
			parent.states.text = str('DAIR')
		states.UAIR:
			parent.play_animation('UAIR')
			parent.states.text = str('UAIR')
		states.FAIR:
			parent.play_animation('FAIR')
			parent.states.text = str('FAIR')
		states.BAIR:
			parent.play_animation('BAIR')
			parent.states.text = str('BAIR')
		states.GROUND_ATTACK:
			parent.states.text = str('GROUND_ATTACK')
		states.DOWN_TILT:
			parent.play_animation('Down_Tilt')
			parent.states.text = str('DOWN_TILT')
		states.UP_TILT:
			parent.play_animation('Up_Tilt')
			parent.states.text = str('UP_TILT')
		states.FORWARD_TILT:
			parent.play_animation('Forward_Tilt')
			parent.states.text = str('FORWARD_TILT')
		states.JAB:
			parent.play_animation('Jab')
			parent.states.text = str('JAB')

func exit_state( old_state, new_state):
	pass  # Define behavior when exiting a state

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func TILT():
	if state_includes([states.STAND,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK]):
		return true

func AIREAL():
	if state_includes([states.AIR, states.NAIR, states.FAIR, states.UAIR, states.BAIR]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false

func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y +=parent.FALLSPEED
	if Input.is_action_just_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall :
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_value(3, false)
		parent.velocity.y = parent.MAXFALLSPEED
		
	if  abs(parent.velocity.x) >=  abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
				
				
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL#*2
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL#*2
		
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/ 5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL / 5

func Landing():
	if state_includes([states.AIR, states.NAIR, states.FAIR, states.BAIR]):
		if (parent.GroundL.is_colliding() or parent.GroundR.is_colliding()) and parent.velocity.y >= 0:
				var collider = parent.GroundL.get_collider()
				parent.frame = 0
				if parent.velocity.y > 0:
					parent.velocity.y = 0
				parent.fastfall = false
				return true
			
		elif parent.GroundR.is_colliding() and parent.velocity.y > 0:
				var collider2 = parent.GroundR.get_collider()
				parent.frame = 0
				if parent.velocity.y > 0:
					parent.velocity.y = 0
				parent.fastfall = false
				return true

func Falling():
	if state_includes([states.STAND,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

var kbx
var kby
var pos
var hd
var vd

func hitfreeze(duration, knocback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knocback[0]
	kby = knocback[1]
	hd = knocback[2]
	vd = knocback[3]
