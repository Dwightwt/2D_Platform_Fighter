## This code is for the atack state of the enemy

extends NodeState

# Exports allow these variables to be set in the Godot editor, giving flexibility to adjust settings per instance of this script.
@export var character_body_2d: CharacterBody2D  # Reference to the enemy's CharacterBody2D, allowing movement control.
@export var animated_sprite_2d: AnimatedSprite2D  # Reference to the enemy's AnimatedSprite2D, controlling animations.
@export var speed : int  # Base speed for the enemy movement.

# Internal variables that do not appear in the editor but are used for logic within the script.
var Sonic: CharacterBody2D  # Reference to the player (Sonic) used for positioning and tracking.
var max_speed : int # Maximum speed the enemy can reach, set in `enter` function based on `speed`.

# `on_process` is an idle process function but is currently empty. Can be used for non-physics related updates.
func on_process(delta: float):
	pass

# `on_physics_process` is called each physics frame, responsible for physics-related actions like movement.
func on_physics_process(delta: float):
	var direction: int  # Determines the direction the enemy should move (left or right).

	# Check if enemy is to the right or left of Sonic.
	if character_body_2d.global_position > Sonic.global_position:
		animated_sprite_2d.flip_h = false  # Face left by setting `flip_h` to false.
		direction = -1  # Move left
	elif character_body_2d.global_position < Sonic.global_position:
		animated_sprite_2d.flip_h = true  # Face right by setting `flip_h` to true.
		direction = 1  # Move right

	# Play the attack animation.
	animated_sprite_2d.play("attack")

	# Update the enemy's velocity in the x-direction based on direction, speed, and delta.
	character_body_2d.velocity.x += direction * speed * delta

	# Clamp the velocity to ensure it doesn’t exceed `max_speed` in either direction.
	character_body_2d.velocity.x = clampi(character_body_2d.velocity.x, -max_speed, max_speed)

	# Move the character, applying the updated velocity.
	character_body_2d.move_and_slide()

# `enter` function is called when this state is entered.
func enter():
	# Get the player node from the group "Sonic" and store it in `Sonic`.
	Sonic = get_tree().get_nodes_in_group("Sonic")[0] as CharacterBody2D
	
	# Set `max_speed` as a slightly higher value than `speed`, giving the enemy a speed cap.
	max_speed = speed + 20

# `exit` function is called when this state is exited. 
func exit():
	pass
