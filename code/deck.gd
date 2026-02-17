extends Control

#will hold and handle all the logic related to player cards

#holds references to all the cards in the deck
var full_deck: Array[Control]
var card_scene: PackedScene = preload("res://scenes/card.tscn")
var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

func _ready() -> void:
	card_y = get_tree().root.get_visible_rect().size.y - card_height - bottom_margin
	#set to encompass the bottom of the screen where the cards and piles
	#will be located
	init_cards()
	init_pile_transforms()

#sets the position and size of the draw and discard pile
func init_pile_transforms():
	$"DrawPile".set_transforms()
	$"DiscardPile".set_transforms()

#moves cards from the deck to the draw pile and shuffles it
func combat_start():
	for i in range(full_deck.size()):
		$"DrawPile".card_array.append(full_deck[i])
	$"DrawPile".card_array.shuffle()

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

#draws cards from the draw pile at the start of every turn
func draw_cards():
	for i in range(get_parent().cards_per_turn):
		#gets the card at the top of the draw pile
		var current_card = $"DrawPile".card_array.back()
		$"DrawPile".remove_card(current_card)
		$"HandContainer".add_card(current_card)
		current_card.update_debug_label()

#_on_empty_draw_pile event action function should handle when cards need to be drawn but the draw pile is empty, move all cards from discard pile
#to draw pile then shuffle

#_on_card_played event action function, should handle moving played card
#to the discard pile

#end of combat function, should handle clearing the 2 piles and the hand
