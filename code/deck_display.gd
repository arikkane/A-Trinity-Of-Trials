extends CanvasLayer

var card_rows: Array[Control]
var card_horizontal_margin = 20
var card_width = 192
var card_type_filter = {
	"Damage": true,
	"Utility": true
}

func show_deck():
	show()
	update_cards()

func update_cards():
	var row_count = get_row_count()
	if card_rows.size() < row_count:
		add_rows(row_count-card_rows.size())
	elif card_rows.size() > row_count:
		remove_rows((card_rows.size())-row_count)
	for i in range(GameManager.Deck.full_deck.size()):
		var current_card = GameManager.Deck.full_deck[i]
		current_card.useable = false
		card_rows[floor(i/5)].add_child(current_card)
		current_card.init_debug_label()
		current_card.update_debug_label()
		current_card.position.x = (card_width+card_horizontal_margin)*(i%5)
		print_card(current_card)

func get_row_count() -> int:
	var total = 0
	for card in GameManager.Deck.full_deck.size():
		if filter[card.card_type]:
			total += 1
	return ceil(total/5)

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

func connect_filter_menu_signals():
	$"DeckContainer/FilterAndSortMenu/FilterMenu/FilterType".item_selected.connect(_on_filter_type_selected)
	$"DeckContainer/FilterAndSortMenu/FilterMenu/FilterBy".item_selected.connect(_on_filter_by_selected)

func connect_sort_menu_signals():
	$"DeckContainer/FilterAndSortMenu/SortMenu/SortType".item_selected.connect(_on_sort_type_selected)
	$"DeckContainer/FilterAndSortMenu/SortMenu/SortBy".item_selected.connect(_on_sort_by_selected)

func _on_filter_type_selected(index):
	print("filter type selected: " + $"DeckContainer/FilterAndSortMenu/FilterMenu/FilterType".get_item_text(index))

func _on_filter_by_selected(index):
	print("filter by selected: " + $"DeckContainer/FilterAndSortMenu/FilterMenu/FilterBy".get_item_text(index))

func _on_sort_type_selected(index):
	print("sort type selected: " + $"DeckContainer/FilterAndSortMenu/SortMenu/SortType".get_item_text(index))

func _on_sort_by_selected(index):
	print("sort by selected: " + $"DeckContainer/FilterAndSortMenu/SortMenu/SortBy".get_item_text(index))

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
