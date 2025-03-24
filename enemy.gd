//Basic Movement for Enemies in Challenge Mode

extends CharacterBody2D
@export var weight = 100
@export var percentage = 0
const GRAVITY = 1000
const SPEED = 1500

var current_state : State
enum State {Idle, Walk}
var direction : Vector2 = Vector2.LEFT


func _ready():
	current_state = State.Idle

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	move_and_slide()
	
func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta : float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	current_state =State.Idle


func enemy_walk(delta : float):
	velocity.x = direction.x * SPEED * delta
	current_state = State.Walk
