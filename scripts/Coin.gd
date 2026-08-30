extends Node2D
class_name Coin

@export var value: int = 1
@export var scatter_duration: float = 0.1
@export var scatter_distance_min: float = 50.0
@export var scatter_distance_max: float = 100.0
@export var collect_duration: float = 0.18
@export var target_ui_position: Vector2 = Vector2(80, 40)

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var sound_coin: AudioStream = preload("res://assets/audio/coin.wav")

func _ready() -> void:
	audio_player.stream = sound_coin
	_animate_scatter_and_collect()

func _animate_scatter_and_collect() -> void:
	var angle: float = randf_range(-PI * 0.9, -PI * 0.1)
	var distance: float = randf_range(scatter_distance_min, scatter_distance_max)
	var burst_offset: Vector2 = Vector2(cos(angle), sin(angle)) * distance
	var land_pos: Vector2 = position + burst_offset
	
	scale = Vector2(0.2, 0.2)
	
	var tween: Tween = create_tween()
	# Fast snappy scatter
	tween.tween_property(self, "scale", Vector2.ONE, 0.05)
	tween.parallel().tween_property(self, "position", land_pos, scatter_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation", randf_range(-PI, PI), scatter_duration)
	
	# Micro pause
	tween.tween_interval(0.04)
	
	# Fast flight towards UI counter
	tween.tween_property(self, "position", target_ui_position, collect_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.4, 0.4), collect_duration)
	
	tween.tween_callback(_on_collected)

func _on_collected() -> void:
	GameManager.add_coins(value)
	_play_collect_audio()

func _play_collect_audio() -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = sound_coin
	player.pitch_scale = randf_range(0.94, 1.06)
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	queue_free()
