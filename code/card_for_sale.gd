extends Control

#This script handles the cards that are in stock at the shop

var card_data: CardData
var card_price: int
var can_afford: bool
var purchased: bool = false

signal card_purchased

#------------------------------------
# This function checks if the player
# can currently afford the card,
# changing the price font to green if
# they can, and red if they cant
#------------------------------------
func check_if_affordable():
	if GameManager.PlayerGold >= card_price:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#00a300")
		can_afford = true
	else:
		$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#dd2400")
		can_afford = false

#------------------------------------
# This function generates a random
# price for the card between +-10 of
# the base price
#------------------------------------
func generate_price(base_price):
	card_price = randi_range(base_price-10, base_price+10)

#---------------------------------------
# This function updates the labels that
# display the cards info, as well as the
# price tag
#---------------------------------------
func update_labels():
	$"CardTexture/Name".text = str(card_data.name)
	$"CardTexture/Type".text = str(card_data.type)
	$"CardTexture/Description".text = str(card_data.description)
	$"PricetagTexture/PriceText".text = str(str(card_price))
	check_if_affordable()

#-----------------------------------------
# This function deletes the cards texture
# when the card is purchased, as well as
# changes the price label to SOLD
#-----------------------------------------
func update_purchased_card():
	$"CardTexture".queue_free()
	$"PricetagTexture/PriceText".text = "SOLD"
	$"PricetagTexture/PriceText".add_theme_color_override("default_color", "#dd2400")

#------------------------------Input Handling----------------------------------------------
func _on_card_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and can_afford:
			GameManager.Deck.full_deck.append(card_data)
			GameManager.PlayerGold -= card_price
			purchased = true
			update_purchased_card()
			card_purchased.emit()
			GameManager.UIOverlay.update_gold()
