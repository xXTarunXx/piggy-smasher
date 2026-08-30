extends Node2D
class_name Piggy

signal piggy_destroyed(reward_coins: int)

@export_group("Stats")
@export var tier_name: String = "Common"
@export var max_hp: int = 3
@export var coin_reward: int = 2
@export var tier_color: Color = Color(1.0, 1.0, 1.0)
@export var base_scale: float = 1.0

@export_group("Juice & Feel (Fast Speed)")
@export var hit_stop_duration: float = 0.015
@export var shake_trauma_hit: float = 0.16
@export var shake_trauma_crit: float = 0.35
@export var shake_trauma_break: float = 0.5
@export var hit_particle_count: int = 12
@export var break_particle_count: int = 32

@export_group("Movement Bounds")
@export var min_bounds: Vector2 = Vector2(160.0, 160.0)
@export var max_bounds: Vector2 = Vector2(990.0, 520.0)
@export var move_speed: float = 180.0

@export_group("References")
@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")

var current_hp: int
var is_moving: bool = false
var move_tween: Tween = null
var current_target: Vector2 = Vector2.ZERO
var separation_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio
@onready var hit_particles: CPUParticles2D = $HitParticles
@onready var break_particles: CPUParticles2D = $BreakParticles
@onready var hp_bar: ProgressBar = $ProgressBar

var sound_break: AudioStream = preload("res://assets/audio/break.wav")

func _ready() -> void:
	add_to_group("piggies")
	current_hp = max_hp
	area.input_event.connect(_on_area_2d_input_event)
	
	if hit_particles != null:
		hit_particles.amount = hit_particle_count
		hit_particles.lifetime = 0.08
	if break_particles != null:
		break_particles.amount = break_particle_count
		break_particles.lifetime = 0.14
	
	_play_spawn_animation()
	_update_hp_bar()
	_schedule_next_movement(randf_range(0.1, 0.4))

func _play_spawn_animation() -> void:
	# Fast snappy spawn-in pop
	scale = Vector2.ONE * (base_scale * 0.2)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * base_scale, 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func setup_tier(p_name: String, p_hp: int, p_coins: int, p_color: Color, p_sound: AudioStream, p_scale: float = 1.0) -> void:
	tier_name = p_name
	max_hp = p_hp
	current_hp = p_hp
	coin_reward = p_coins
	tier_color = p_color
	base_scale = p_scale
	if p_sound != null:
		sound_break = p_sound
	
	if sprite != null:
		sprite.self_modulate = p_color
	if break_particles != null:
		break_particles.color = p_color
	
	scale = Vector2.ONE * base_scale
	_update_hp_bar()

func _process(delta: float) -> void:
	_apply_soft_separation(delta)
	
	# Clamp position within table arena bounds
	global_position.x = clampf(global_position.x, min_bounds.x, max_bounds.x)
	global_position.y = clampf(global_position.y, min_bounds.y, max_bounds.y)

func _apply_soft_separation(delta: float) -> void:
	# Soft repulsion force to prevent piggies from stacking directly on each other
	var repulsion: Vector2 = Vector2.ZERO
	var piggies: Array = get_tree().get_nodes_in_group("piggies")
	var min_distance: float = 95.0 * base_scale
	
	for other in piggies:
		if other == self or not is_instance_valid(other):
			continue
		var diff: Vector2 = global_position - other.global_position
		var dist: float = diff.length()
		if dist > 0.0 and dist < min_distance:
			var force: float = (min_distance - dist) / min_distance
			repulsion += diff.normalized() * (force * 120.0)
	
	if repulsion != Vector2.ZERO:
		global_position += repulsion * delta

func _schedule_next_movement(delay: float) -> void:
	if current_hp <= 0:
		return
	var timer: SceneTreeTimer = get_tree().create_timer(delay)
	timer.timeout.connect(_start_move_to_random_target)

func _start_move_to_random_target() -> void:
	if current_hp <= 0 or not is_inside_tree():
		return
	
	# Pick a random destination within table bounds
	var target_x: float = randf_range(min_bounds.x, max_bounds.x)
	var target_y: float = randf_range(min_bounds.y, max_bounds.y)
	current_target = Vector2(target_x, target_y)
	
	var distance: float = global_position.distance_to(current_target)
	if distance < 30.0:
		_schedule_next_movement(randf_range(0.3, 0.8))
		return
	
	var duration: float = clampf(distance / move_speed, 0.6, 2.2)
	is_moving = true
	
	# Lean / tilt slightly in the direction of movement
	var move_dir: Vector2 = (current_target - global_position).normalized()
	var tilt_angle: float = clampf(move_dir.x * 0.12, -0.15, 0.15)
	
	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	
	move_tween = create_tween().set_parallel(true)
	# Ease in, ease out smooth movement (acceleration and deceleration)
	move_tween.tween_property(self, "global_position", current_target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "rotation", tilt_angle, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	move_tween.chain().tween_property(self, "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	move_tween.tween_callback(_on_movement_finished)

func _on_movement_finished() -> void:
	is_moving = false
	rotation = 0.0
	# Brief idle moment at destination before picking next target
	var idle_duration: float = randf_range(0.3, 0.85)
	_schedule_next_movement(idle_duration)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Handled globally by Main.gd to support hammer splash radius and multi-targeting cleanly
	pass

func is_overlapping_circle(circle_pos: Vector2, circle_radius: float) -> bool:
	var hitbox_radius: float = 44.0 * base_scale
	return global_position.distance_to(circle_pos) <= (circle_radius + hitbox_radius)

func take_damage(damage: int, is_crit: bool = false) -> void:
	if current_hp <= 0:
		return
	
	current_hp -= damage
	_update_hp_bar()
	
	if current_hp > 0:
		_on_hit(is_crit)
	else:
		die(is_crit)

func _on_hit(is_crit: bool) -> void:
	_play_audio(hit_audio, 1.2 if is_crit else 1.0)
	_trigger_shake(shake_trauma_crit if is_crit else shake_trauma_hit)
	_animate_hit_impact(is_crit)
	if hit_particles != null:
		hit_particles.restart()
	_apply_hit_stop(hit_stop_duration * (1.5 if is_crit else 1.0))

func _animate_hit_impact(is_crit: bool) -> void:
	# 8x snappier squash & stretch tween
	var tween: Tween = create_tween()
	var squash_x: float = 1.35 if is_crit else 1.2
	var squash_y: float = 0.7 if is_crit else 0.82
	sprite.scale = Vector2(squash_x, squash_y)
	sprite.modulate = Color(2.5, 2.2, 1.2) if is_crit else Color(2.0, 2.0, 2.0)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.035)

func _update_hp_bar() -> void:
	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		hp_bar.visible = (current_hp < max_hp or max_hp > 3)

func _trigger_shake(amount: float) -> void:
	var camera: MainCamera = get_tree().get_first_node_in_group("camera") as MainCamera
	if camera != null:
		camera.add_trauma(amount)

func _apply_hit_stop(duration: float) -> void:
	if duration <= 0.0:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func _play_audio(player: AudioStreamPlayer2D, pitch_multiplier: float = 1.0) -> void:
	if player != null and player.stream != null:
		player.pitch_scale = randf_range(0.92, 1.08) * pitch_multiplier
		player.play()

func die(is_crit: bool = false) -> void:
	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	
	remove_from_group("piggies")
	_trigger_shake(shake_trauma_break * (1.2 if is_crit else 1.0))
	_apply_hit_stop(hit_stop_duration * 1.5)
	
	# Spawn break audio independently
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = sound_break
	audio.pitch_scale = randf_range(0.94, 1.06)
	get_tree().root.add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)
	
	# Spawn detached break particles
	if break_particles != null:
		var burst: CPUParticles2D = break_particles.duplicate() as CPUParticles2D
		burst.position = global_position
		burst.lifetime = 0.14
		burst.emitting = true
		burst.one_shot = true
		get_parent().add_child(burst)
		get_tree().create_timer(burst.lifetime + 0.05).timeout.connect(burst.queue_free)
	
	# Spawn scattered coins
	_spawn_coins(coin_reward)
	
	piggy_destroyed.emit(coin_reward)
	queue_free()

func _spawn_coins(count: int) -> void:
	if coin_scene == null:
		return
	
	for i in range(count):
		var coin: Coin = coin_scene.instantiate() as Coin
		coin.position = global_position
		coin.value = 1
		get_parent().add_child(coin)
