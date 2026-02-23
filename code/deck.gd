extends Control

#holds references to all the cards in the deck
var full_deck: Array[Control]
var card_scene: PackedScene = preload("res://scenes/card.tscn")
var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

func display_full_deck():
	for i in range(full_deck.size()):
		print("Card #" + str(i) + ": " + str(full_deck[i].card_id))

#initalize cards function, should be called when run is started
func init_cards():
	#generates placeholder cards for the initial prototype
	for i in range(20):
		full_deck.append(card_scene.instantiate())
		full_deck.back().card_id = i
	for i in range(10):
		full_deck[i].type = "Damage"
		full_deck[i].damage = 5
		full_deck[i].description = "Deals " + str(full_deck[i].damage) + " damage to the target"
	for i in range(5): 
		full_deck[i+10].type = "Utility"
		full_deck[i+10].block = 4
		full_deck[i+10].description = "Applies " + str(full_deck[i].block) + " block to the user"
	for i in range(5):
		full_deck[i+15].type = "Utility"
		full_deck[i+15].heal = 2
		full_deck[i+15].description = "Heals the user for " + str(full_deck[i].heal) + " health"
