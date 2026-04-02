extends CanvasLayer

var card_rows: Array[Control]
var card_horizontal_margin = 20
var card_width = 192

#stores the current selection for both sort menus
var sort_type;
var sort_by;
#enumerators that contain all the options for each menu, when a new option is added in the menu, it should also manually be added here
enum SortType{
	ID
}
enum SortBy{
	Ascending,
	Descending
}

func show_deck():
	show()
	update_cards()

#-------------------------------------------------------------
# This function should be called every time the deck display
# is made visible, as it updates the rows of cards, reflecting
# any changes that were made to the overall deck.
#
# WARNING: The sort functions are not implemented yet as the
# cards are also not fully implemented yet. The issue is 
# trying to sort the deck array without messing with the 
# internal order of the deck mid-combat requires the full_deck
# array to be duplicated, which is not possible to do with 
# an array of object instances without manually copying each
# parameter of the card over to the card copies, which is 
# very inefficient. The deck array should be changed to hold
# the cards as data instead of objects, as this makes them 
# easier to duplicate and manipulate.
#-------------------------------------------------------------
func update_cards():
	var row_count = ceil(GameManager.Deck.full_deck.size()/5)
	#var sorted_deck = sort_deck()
	if card_rows.size() < row_count:
		add_rows(row_count-card_rows.size())
	elif card_rows.size() > row_count:
		remove_rows((card_rows.size())-row_count)
	for i in range(GameManager.Deck.full_deck.size()):
		var current_card = GameManager.Deck.full_deck[i]
		#once sort is implemented, delete above line and uncomment below line
		#var current_card = sorted_deck[i]
		card_rows[i/5].add_child(current_card)
		current_card.useable = false
		current_card.init_debug_label()
		current_card.update_debug_label()
		current_card.position.x = (card_width+card_horizontal_margin)*(i%5)
		print_card(current_card)

func sort_deck() -> Array[Control]:
	var full_deck = GameManager.Deck.full_deck.duplicate()
	match sort_type:
		SortType.ID:
			match sort_by:
				SortBy.Ascending:
					full_deck.sort_custom(sort_id_by_ascending)
				SortBy.Descending:
					full_deck.sort_custom(sort_id_by_descending)
	return full_deck

func sort_id_by_ascending(card_a, card_b):
	return card_a.card_id < card_b.card_id

func sort_id_by_descending(card_a, card_b):
	return card_a.card_id > card_b.card_id

func add_rows(count):
	for i in range(count):
		var current_row = Control.new()
		current_row.custom_minimum_size = Vector2(1040,350)
		
		card_rows.append(current_row)
		$"DeckContainer/DeckScrollContainer/CardRowContainer".add_child(current_row)
		current_row.position.y = 350*(card_rows.size()-1)

func remove_rows(count):
	for i in range(card_rows.size()-1, count, -1):
		card_rows.erase(card_rows.back())

func connect_sort_menu_signals():
	$"DeckContainer/FilterAndSortMenu/SortMenu/SortType".item_selected.connect(_on_sort_selected)
	$"DeckContainer/FilterAndSortMenu/SortMenu/SortBy".item_selected.connect(_on_sort_selected)

func _on_sort_selected(index):
	sort_type = $"DeckContainer/FilterAndSortMenu/SortMenu/SortType".get_selected_id()
	sort_by = $"DeckContainer/FilterAndSortMenu/SortMenu/SortBy".get_selected_id()

#--------------------------------Debug Functions---------------------------------------
func print_card(card):
	print("ID: " + str(card.card_id))
	print("Type: " + str(card.type))
	if card.type == "Damage":
		print("Damage: " + str(card.damage))
	elif card.type == "Utility":
		print("Block: " + str(card.block))
		print("Heal: " + str(card.heal))
	print("Description: " + str(card.description))
