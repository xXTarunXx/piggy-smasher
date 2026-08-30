extends Node

signal coins_changed(new_amount: int)
signal upgrade_purchased(upgrade_name: String)

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)

# Upgrade Levels
var hit_damage_level: int = 0
var auto_hit_level: int = 0
var crit_level: int = 0
var hammer_radius_level: int = 0

# Upgrade Constants
const MAX_CRIT_LEVEL: int = 5 # 75% max
const MAX_RADIUS_LEVEL: int = 10
const BASE_HAMMER_RADIUS: float = 24.0
const RADIUS_PER_LEVEL: float = 12.0

# Upgrade Calculations
func get_hit_damage() -> int:
	return 1 + hit_damage_level

func get_hit_damage_cost() -> int:
	return int(8 * pow(1.5, hit_damage_level))

func get_auto_hit_interval() -> float:
	if auto_hit_level <= 0:
		return 0.0
	return maxf(0.35, 1.5 - (auto_hit_level - 1) * 0.25)

func get_auto_hit_cost() -> int:
	return int(20 * pow(1.55, auto_hit_level))

func get_crit_chance() -> float:
	return minf(0.75, crit_level * 0.15)

func get_crit_cost() -> int:
	return int(12 * pow(1.5, crit_level))

func get_hammer_radius() -> float:
	return BASE_HAMMER_RADIUS + hammer_radius_level * RADIUS_PER_LEVEL

func get_hammer_radius_cost() -> int:
	return int(18 * pow(1.55, hammer_radius_level))

# Purchase Actions
func buy_hit_damage() -> bool:
	var cost: int = get_hit_damage_cost()
	if coins >= cost:
		coins -= cost
		hit_damage_level += 1
		upgrade_purchased.emit("hit_damage")
		return true
	return false

func buy_auto_hit() -> bool:
	var cost: int = get_auto_hit_cost()
	if coins >= cost:
		coins -= cost
		auto_hit_level += 1
		upgrade_purchased.emit("auto_hit")
		return true
	return false

func buy_crit() -> bool:
	var cost: int = get_crit_cost()
	if coins >= cost and crit_level < MAX_CRIT_LEVEL:
		coins -= cost
		crit_level += 1
		upgrade_purchased.emit("crit")
		return true
	return false

func buy_hammer_radius() -> bool:
	var cost: int = get_hammer_radius_cost()
	if coins >= cost and hammer_radius_level < MAX_RADIUS_LEVEL:
		coins -= cost
		hammer_radius_level += 1
		upgrade_purchased.emit("hammer_radius")
		return true
	return false

# Combat Calculations
func calculate_hit_damage() -> Dictionary:
	var base_dmg: int = get_hit_damage()
	var is_crit: bool = false
	if get_crit_chance() > 0.0 and randf() < get_crit_chance():
		base_dmg *= 2
		is_crit = true
	return {
		"damage": base_dmg,
		"is_crit": is_crit
	}

func add_coins(amount: int) -> void:
	coins += amount

func reset() -> void:
	coins = 0
	hit_damage_level = 0
	auto_hit_level = 0
	crit_level = 0
	hammer_radius_level = 0
