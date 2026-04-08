extends Control

var card_data: CardData
var card_price: int
var can_afford: bool

func check_if_affordable():
	if GameManager.PlayerGold >= card_price:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#00a300")
		can_afford = true
	else:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "dd2400")
		can_afford = false

func generate_price(base_price):
	card_price = randi_range(base_price-10, base_price+10)

func update_labels():
	$"CardTexture/Type".add_text(card_data.type)
	$"CardTexture/Description".add_text(card_data.description)
	$"PricetagTexture/PriceText".add_text(str(card_price))
	check_if_affordable()
