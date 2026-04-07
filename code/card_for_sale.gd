extends Control

var card_data: CardData
var card_price: int
var can_afford: bool

func is_affordable():
	can_afford = GameManager.PlayerGold >= card_price
	if can_afford:
		add_theme_color_override("default", "#00a300")

func generate_price(base_price):
	card_price = randi_range(base_price-10, base_price+10)

func update_labels():
	
