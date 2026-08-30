extends Node2D
class_name CursorCircle

@export var circle_color: Color = Color(1.0, 0.88, 0.4, 0.75)
@export var dash_count: int = 24
@export var line_width: float = 2.0

var current_radius: float = 24.0
var visual_scale: float = 1.0

func _ready() -> void:
	z_index = 100
	current_radius = GameManager.get_hammer_radius()
	GameManager.upgrade_purchased.connect(_on_upgrade_purchased)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pulse_on_click()

func _on_upgrade_purchased(upgrade_name: String) -> void:
	if upgrade_name == "hammer_radius":
		var tween: Tween = create_tween()
		tween.tween_property(self, "current_radius", GameManager.get_hammer_radius(), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _pulse_on_click() -> void:
	var tween: Tween = create_tween()
	visual_scale = 1.18
	tween.tween_property(self, "visual_scale", 1.0, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var r: float = current_radius * visual_scale
	if r <= 0.0:
		return
	
	# Draw dashed circle outline
	var step_angle: float = TAU / float(dash_count)
	var dash_angle: float = step_angle * 0.55
	
	for i in range(dash_count):
		var start_angle: float = i * step_angle
		var end_angle: float = start_angle + dash_angle
		draw_arc(Vector2.ZERO, r, start_angle, end_angle, 6, circle_color, line_width, true)
	
	# Center dot
	draw_circle(Vector2.ZERO, 2.0, circle_color)
