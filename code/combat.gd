extends Node

var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

func _ready() -> void:
	combat_start()
	draw_cards()

#moves cards from the deck to the draw pile and shuffles it
func combat_start():
	card_y = get_tree().root.get_visible_rect().size.y - card_height - bottom_margin
	init_pile_transforms()
	for i in range(GameManager.Deck.full_deck.size()):
		$"DrawPile".card_array.append(GameManager.Deck.full_deck[i])
	$"DrawPile".card_array.shuffle()
	$"DrawPile".display_cards()

#sets the position and size of the draw and discard pile
func init_pile_transforms():
	$"DrawPile".set_transforms()
	$"DiscardPile".set_transforms()

#draws cards from the draw pile at the start of every turn
func draw_cards():
	for i in range(GameManager.CardsDrawnPerTurn):
		#gets the card at the top of the draw pile
		var current_card = $"DrawPile".card_array.back()
		$"DrawPile".remove_card(current_card)
		$"HandContainer".add_card(current_card)
		current_card.update_debug_label()

#initalize enemy function

#handle player turn functionality
