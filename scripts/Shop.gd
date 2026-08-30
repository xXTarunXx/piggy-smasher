extends Control
class_name Shop

@onready var damage_cost_label: Label = %DamageCostLabel
@onready var damage_info_label: Label = %DamageInfoLabel
@onready var damage_buy_button: Button = %DamageBuyButton

@onready var auto_cost_label: Label = %AutoCostLabel
@onready var auto_info_label: Label = %AutoInfoLabel
@onready var auto_buy_button: Button = %AutoBuyButton

@onready var crit_cost_label: Label = %CritCostLabel
@onready var crit_info_label: Label = %CritInfoLabel
@onready var crit_buy_button: Button = %CritBuyButton

@onready var radius_cost_label: Label = %RadiusCostLabel
@onready var radius_info_label: Label = %RadiusInfoLabel
@onready var radius_buy_button: Button = %RadiusBuyButton

@onready var close_button: Button = %CloseButton

func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.upgrade_purchased.connect(_on_upgrade_purchased)
	
	damage_buy_button.pressed.connect(_on_damage_buy_pressed)
	auto_buy_button.pressed.connect(_on_auto_buy_pressed)
	crit_buy_button.pressed.connect(_on_crit_buy_pressed)
	radius_buy_button.pressed.connect(_on_radius_buy_pressed)
	if close_button != null:
		close_button.pressed.connect(toggle_visibility)
	
	refresh_shop()

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		refresh_shop()

func _on_coins_changed(_new_amount: int) -> void:
	if visible:
		refresh_shop()

func _on_upgrade_purchased(_upgrade_name: String) -> void:
	refresh_shop()

func _on_damage_buy_pressed() -> void:
	GameManager.buy_hit_damage()

func _on_auto_buy_pressed() -> void:
	GameManager.buy_auto_hit()

func _on_crit_buy_pressed() -> void:
	GameManager.buy_crit()

func _on_radius_buy_pressed() -> void:
	GameManager.buy_hammer_radius()

func refresh_shop() -> void:
	var coins: int = GameManager.coins
	
	# 1. Damage
	var dmg_cost: int = GameManager.get_hit_damage_cost()
	damage_cost_label.text = "%d Coins" % dmg_cost
	damage_info_label.text = "Current: %d Dmg (+1)" % GameManager.get_hit_damage()
	damage_buy_button.disabled = (coins < dmg_cost)
	
	# 2. Auto Hit
	var auto_cost: int = GameManager.get_auto_hit_cost()
	auto_cost_label.text = "%d Coins" % auto_cost
	if GameManager.auto_hit_level == 0:
		auto_info_label.text = "Locked (Hit every 1.5s)"
	else:
		auto_info_label.text = "Level %d (Hit every %.2fs)" % [GameManager.auto_hit_level, GameManager.get_auto_hit_interval()]
	auto_buy_button.disabled = (coins < auto_cost)
	
	# 3. Crit Chance
	var crit_cost: int = GameManager.get_crit_cost()
	var crit_pct: int = int(GameManager.get_crit_chance() * 100)
	crit_cost_label.text = "%d Coins" % crit_cost
	if GameManager.crit_level >= GameManager.MAX_CRIT_LEVEL:
		crit_info_label.text = "MAX (75% Chance)"
		crit_buy_button.disabled = true
		crit_buy_button.text = "MAX"
	else:
		crit_info_label.text = "Current: %d%% (+15%%)" % crit_pct
		crit_buy_button.disabled = (coins < crit_cost)
		crit_buy_button.text = "Upgrade"
	
	# 4. Hammer Radius
	var radius_cost: int = GameManager.get_hammer_radius_cost()
	var current_rad: int = int(GameManager.get_hammer_radius())
	radius_cost_label.text = "%d Coins" % radius_cost
	if GameManager.hammer_radius_level >= GameManager.MAX_RADIUS_LEVEL:
		radius_info_label.text = "MAX (%dpx Area)" % current_rad
		radius_buy_button.disabled = true
		radius_buy_button.text = "MAX"
	else:
		if GameManager.hammer_radius_level == 0:
			radius_info_label.text = "Direct Hit (Unlock AOE)"
		else:
			radius_info_label.text = "Level %d (%dpx Splash)" % [GameManager.hammer_radius_level, current_rad]
		radius_buy_button.disabled = (coins < radius_cost)
		radius_buy_button.text = "Upgrade"
