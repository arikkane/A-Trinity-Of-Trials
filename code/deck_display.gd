extends CanvasLayer

var card_rows: Array[Control]
var card_horizontal_margin = 20
var card_width = 192

#stores the current selection for both sort menus
var sort_type;
var sort_by;

#enumerators that contain all the options for each menu, when a new option is added in the menu, it should also manually be added here
enum SortType{
	ID,
	Name
}
enum SortBy{
	Ascending,
	Descending
}

func _ready():
	sort_type = SortType.ID
	sort_by = SortBy.Ascending

#-------------------------------------------------------------
# This function should be called every time the deck display
# is made visible, as it updates the rows of cards, reflecting
# any changes that were made to the overall deck.
#-------------------------------------------------------------
func update_cards():
	#gets the amount of card rows based on the amount of cards in the deck
	var row_count = ceil(float(GameManager.Deck.full_deck.size())/5)
	var sorted_deck = sort_deck()
	if card_rows.size() < row_count:
		add_rows(row_count-card_rows.size())
	elif card_rows.size() > row_count:
		remove_rows((card_rows.size())-row_count)
	for i in range(sorted_deck.size()):
		var current_card = sorted_deck[i].scene.instantiate()
		current_card.card_data = sorted_deck[i]
		card_rows[i/5].add_child(current_card)
		current_card.useable = false
		current_card.init_debug_label()
		current_card.update_debug_label()
		current_card.position.x = (card_width+card_horizontal_margin)*(i%5)
		#print_card(current_card)

#--------------------------------------------------------------
# This function gets a duplicate of the full deck and sorts it
# based on the selected sort menu options
#--------------------------------------------------------------
func sort_deck() -> Array:
	var full_deck = GameManager.Deck.full_deck.duplicate()
	match sort_type:
		SortType.ID:
			match sort_by:
				SortBy.Ascending:
					full_deck.sort_custom(func(a,b):return a.id < b.id)
				SortBy.Descending:
					full_deck.sort_custom(func(a,b):return a.id > b.id)
		SortType.Name:
			match sort_by:
				SortBy.Ascending:
					full_deck.sort_custom(func(a,b):return a.name < b.name)
				SortBy.Descending:
					full_deck.sort_custom(func(a,b):return a.name > b.name)
	return full_deck

#----------------------------------------
# This function clears the cards and rows
# before each update to prevent cards 
# being shown more than once
#---------------------------------------- 
func clear_rows():
	for row in card_rows:
		for child in row.get_children():
			child.queue_free()

#--------------------------------------------
# This function creates {count} amount of new
# row containers
#--------------------------------------------
func add_rows(count):
	for i in range(count):
		var current_row = Control.new()
		current_row.custom_minimum_size = Vector2(1040,350)
		
		card_rows.append(current_row)
		$"DeckContainer/DeckScrollContainer/CardRowContainer".add_child(current_row)
		current_row.position.y = 350*(card_rows.size()-1)

#-----------------------------------------------
# This function removes {count} amount of row
# containers from the end of the card_rows array
#-----------------------------------------------
func remove_rows(count):
	for i in range(card_rows.size()-1, count, -1):
		card_rows.erase(card_rows.back())

#----------------------------Input Handling Functions----------------------------------
func _on_sort_type_selected(index):
	print("in _on_sort_type_selected")
	sort_type = index
	clear_rows()
	update_cards()

func _on_sort_by_selected(index):
	print("in _on_sort_by_selected")
	sort_by = index
	clear_rows()
	update_cards()

#--------------------------------Debug Functions---------------------------------------
func print_card(card):
	print("ID: " + str(card.card_data.id))
	print("Type: " + str(card.card_data.type))
	if card.card_data.type == "Damage":
		print("Damage: " + str(card.card_data.damage))
	elif card.card_data.type == "Utility":
		print("Block: " + str(card.card_data.block))
		print("Heal: " + str(card.card_data.heal))
	print("Description: " + str(card.card_data.description))
