extends CanvasLayer

@onready var coin_label: Label = %CoinLabel
@onready var shop_button: Button = %ShopButton
@onready var shop: Shop = %Shop
@onready var menu_button: Button = %MenuButton

var last_coin_amount: int = 0

func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	last_coin_amount = GameManager.coins
	_update_coin_display(last_coin_amount, false)
	
	if shop_button != null and shop != null:
		shop_button.pressed.connect(_on_shop_button_pressed)
		shop.visible = false
	
	if menu_button != null:
		menu_button.pressed.connect(_on_menu_button_pressed)

func _on_shop_button_pressed() -> void:
	if shop != null:
		shop.toggle_visibility()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _on_coins_changed(new_amount: int) -> void:
	var should_pop: bool = (new_amount > last_coin_amount)
	last_coin_amount = new_amount
	_update_coin_display(new_amount, should_pop)

func _update_coin_display(amount: int, animate_pop: bool = false) -> void:
	coin_label.text = "🪙 Coins: %d" % amount
	
	if animate_pop:
		_animate_coin_pop()

func _animate_coin_pop() -> void:
	coin_label.pivot_offset = Vector2(0, coin_label.size.y * 0.5)
	var tween: Tween = create_tween()
	coin_label.scale = Vector2(1.28, 1.28)
	coin_label.modulate = Color(1.3, 1.1, 0.4, 1.0)
	tween.tween_property(coin_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(coin_label, "modulate", Color.WHITE, 0.14)
