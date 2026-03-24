extends CanvasLayer

var card_rows: Array[Control]
var card_horizontal_margin = 20
var card_width = 192
func update_cards():
	var row_count = ceil(GameManager.Deck.full_deck.size()/5)
	if card_rows.size() < row_count:
		add_rows(row_count-card_rows.size()+1)
	for i in range(GameManager.Deck.full_deck.size()):
		var current_card = GameManager.Deck.full_deck[i].duplicate()
		current_card.useable = false
		card_rows[floor(i/5)].add_child(current_card)
		current_card.position.x = (card_width+card_horizontal_margin)*(i%5)

func add_rows(count):
	for i in range(count):
		var current_row = Control.new()
		current_row.custom_minimum_size = Vector2(1040,350)
		
		card_rows.append(current_row)
		$"DeckContainer/DeckScrollContainer/CardRowContainer".add_child(current_row)
		current_row.position.y = 350*(card_rows.size()-1)
