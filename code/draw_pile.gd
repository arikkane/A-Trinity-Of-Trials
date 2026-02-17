extends TextureRect

var card_array: Array[Control]
var Deck: Control = null

func _ready() -> void:
	Deck = get_parent()

#sets size and position of sprite
func set_transforms():
	custom_minimum_size = Vector2(Deck.card_width, Deck.card_height)
	global_position = Vector2(Deck.side_margin, Deck.card_y)

func add_card(card:Control):
	card_array.append(card)
	add_child(card)

func remove_card(card:Control):
	card_array.erase(card)
	remove_child(card)
