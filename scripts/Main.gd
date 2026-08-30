extends Node2D

@export var piggy_scene: PackedScene = preload("res://scenes/Piggy.tscn")
@export var max_concurrent_piggies: int = 5
@export var respawn_delay: float = 0.15

@export var spawn_min_bounds: Vector2 = Vector2(200.0, 200.0)
@export var spawn_max_bounds: Vector2 = Vector2(950.0, 480.0)

@onready var auto_hit_timer: Timer = $AutoHitTimer

var sound_break_common: AudioStream = preload("res://assets/audio/break.wav")
var sound_break_rare: AudioStream = preload("res://assets/audio/break_rare.wav")
var sound_break_epic: AudioStream = preload("res://assets/audio/break_epic.wav")

var tier_definitions: Array = [
	{
		"name": "Common",
		"weight": 70,
		"hp": 3,
		"coins": 2,
		"color": Color(1.0, 1.0, 1.0, 1.0),
		"sound": sound_break_common,
		"scale": 1.0
	},
	{
		"name": "Rare",
		"weight": 24,
		"hp": 8,
		"coins": 10,
		"color": Color(1.0, 0.84, 0.0, 1.0),
		"sound": sound_break_rare,
		"scale": 1.15
	},
	{
		"name": "Epic",
		"weight": 6,
		"hp": 20,
		"coins": 35,
		"color": Color(0.1, 0.9, 1.0, 1.0),
		"sound": sound_break_epic,
		"scale": 1.3
	}
]

func _ready() -> void:
	GameManager.upgrade_purchased.connect(_on_upgrade_purchased)
	_setup_auto_hit_timer()
	_spawn_initial_piggies()

func _spawn_initial_piggies() -> void:
	for i in range(max_concurrent_piggies):
		_spawn_single_piggy()

func _spawn_single_piggy() -> void:
	var living_piggies: Array = get_tree().get_nodes_in_group("piggies")
	if living_piggies.size() >= max_concurrent_piggies:
		return
	
	var tier_data: Dictionary = _choose_weighted_tier()
	var piggy: Piggy = piggy_scene.instantiate() as Piggy
	
	# Pick non-overlapping random initial position
	var spawn_x: float = randf_range(spawn_min_bounds.x, spawn_max_bounds.x)
	var spawn_y: float = randf_range(spawn_min_bounds.y, spawn_max_bounds.y)
	piggy.global_position = Vector2(spawn_x, spawn_y)
	piggy.piggy_destroyed.connect(_on_piggy_destroyed)
	
	add_child(piggy)
	
	piggy.setup_tier(
		tier_data["name"],
		tier_data["hp"],
		tier_data["coins"],
		tier_data["color"],
		tier_data["sound"],
		tier_data["scale"]
	)

func _on_piggy_destroyed(_reward_coins: int) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(respawn_delay)
	timer.timeout.connect(_spawn_single_piggy)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_hammer_click(get_global_mouse_position())

func _handle_hammer_click(click_pos: Vector2) -> void:
	var piggies: Array = get_tree().get_nodes_in_group("piggies")
	if piggies.is_empty():
		return
	
	var radius: float = GameManager.get_hammer_radius()
	var is_upgraded_radius: bool = (GameManager.hammer_radius_level > 0)
	
	var hit_targets: Array = []
	for p in piggies:
		if is_instance_valid(p) and p is Piggy:
			var piggy: Piggy = p as Piggy
			if is_upgraded_radius:
				if piggy.is_overlapping_circle(click_pos, radius):
					hit_targets.append(piggy)
			else:
				if piggy.global_position.distance_to(click_pos) <= (44.0 * piggy.base_scale):
					hit_targets.append(piggy)
	
	if hit_targets.is_empty():
		return
	
	# If unupgraded, target only the single closest piggy
	if not is_upgraded_radius and hit_targets.size() > 1:
		hit_targets.sort_custom(func(a, b): return a.global_position.distance_to(click_pos) < b.global_position.distance_to(click_pos))
		hit_targets = [hit_targets[0]]
	
	var hit_data: Dictionary = GameManager.calculate_hit_damage()
	var dmg: int = hit_data.get("damage", 1)
	var is_crit: bool = hit_data.get("is_crit", false)
	
	for target in hit_targets:
		if is_instance_valid(target):
			target.take_damage(dmg, is_crit)

func _setup_auto_hit_timer() -> void:
	if auto_hit_timer != null:
		auto_hit_timer.timeout.connect(_on_auto_hit_tick)
		_update_auto_hit_interval()

func _update_auto_hit_interval() -> void:
	if auto_hit_timer == null:
		return
	var interval: float = GameManager.get_auto_hit_interval()
	if interval > 0.0:
		auto_hit_timer.wait_time = interval
		if auto_hit_timer.is_stopped():
			auto_hit_timer.start()
	else:
		auto_hit_timer.stop()

func _on_upgrade_purchased(upgrade_name: String) -> void:
	if upgrade_name == "auto_hit":
		_update_auto_hit_interval()

func _on_auto_hit_tick() -> void:
	var piggies: Array = get_tree().get_nodes_in_group("piggies")
	if piggies.is_empty():
		return
	
	var center: Vector2 = Vector2(576.0, 324.0)
	var closest_piggy: Piggy = null
	var min_dist: float = INF
	
	for p in piggies:
		if is_instance_valid(p) and p is Piggy:
			var dist: float = p.global_position.distance_to(center)
			if dist < min_dist:
				min_dist = dist
				closest_piggy = p as Piggy
	
	if closest_piggy != null and is_instance_valid(closest_piggy):
		var hit_data: Dictionary = GameManager.calculate_hit_damage()
		closest_piggy.take_damage(hit_data.get("damage", 1), hit_data.get("is_crit", false))

func _choose_weighted_tier() -> Dictionary:
	var total_weight: int = 0
	for tier in tier_definitions:
		total_weight += tier["weight"]
	
	var roll: int = randi_range(1, total_weight)
	var current_sum: int = 0
	
	for tier in tier_definitions:
		current_sum += tier["weight"]
		if roll <= current_sum:
			return tier
	
	return tier_definitions[0]
