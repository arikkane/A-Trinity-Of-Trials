extends Control

#will hold and handle all the logic related to player cards

#holds references to all the cards in the deck
var full_deck: Array[Control]

func _ready() -> void:
	custom_minimum_size = Vector2(1080, 192)

#initalize cards function, should be called when run is started

#_on_card_played event action function, should handle moving played card
#to the discard pile

#end of combat function, should handle clearing the 2 piles and the hand
