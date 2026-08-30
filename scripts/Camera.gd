extends Camera2D
class_name MainCamera

@export var decay: float = 4.0 # Trauma decay rate per second
@export var max_offset: Vector2 = Vector2(14.0, 10.0) # Maximum pixel shake offset
@export var max_roll: float = 0.04 # Maximum rotation shake in radians

var trauma: float = 0.0 # Trauma level [0.0, 1.0]

func _ready() -> void:
	add_to_group("camera")

func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = maxf(trauma - decay * delta, 0.0)
		_shake()
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func _shake() -> void:
	var amount: float = trauma * trauma # Non-linear falloff for punchier impacts
	rotation = max_roll * amount * randf_range(-1.0, 1.0)
	offset.x = max_offset.x * amount * randf_range(-1.0, 1.0)
	offset.y = max_offset.y * amount * randf_range(-1.0, 1.0)
