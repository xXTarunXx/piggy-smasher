extends Control

@onready var play_button: Button = %PlayButton
@onready var piggy_icon: TextureRect = %PiggyIcon

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	_animate_title_piggy()

func _animate_title_piggy() -> void:
	if piggy_icon == null:
		return
	
	# Gentle floating idle bounce
	var original_y: float = piggy_icon.position.y
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(piggy_icon, "position:y", original_y - 10.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(piggy_icon, "position:y", original_y, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_play_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
