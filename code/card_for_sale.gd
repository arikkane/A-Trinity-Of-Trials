extends Control

var card_data: CardData
var card_price: int
var can_afford: bool
var purchased: bool = false

signal card_purchased

func check_if_affordable():
	if GameManager.PlayerGold >= card_price:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#00a300")
		can_afford = true
	else:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#dd2400")
		can_afford = false

func generate_price(base_price):
	card_price = randi_range(base_price-10, base_price+10)

func update_labels():
	$"CardTexture/Name".text = str(card_data.name)
	$"CardTexture/Type".text = str(card_data.type)
	$"CardTexture/Description".text = str(card_data.description)
	$"PricetagTexture/PriceText".text = str(str(card_price))
	check_if_affordable()

func update_purchased_card():
	$"CardTexture".queue_free()
	$"PricetagTexture/PriceText".text = "SOLD"

func _on_card_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and can_afford:
			GameManager.Deck.full_deck.append(card_data)
			GameManager.PlayerGold -= card_price
			update_purchased_card()
			card_purchased.emit()
			GameManager.UIOverlay.update_gold()
