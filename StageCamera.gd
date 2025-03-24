//Camera for the versus mode

extends Camera2D

@onready var p1 = get_parent().get_node("Sonic")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.position = p1.position
	pass
