extends TextureRect

var card_array: Array[Control]
var Deck: Control = null

func _ready() -> void:
	Deck = get_parent()

func set_transforms():
	custom_minimum_size = Vector2(Deck.card_width, Deck.card_height)
	global_position = Vector2(get_tree().root.get_visible_rect().size.x - Deck.card_width - Deck.side_margin, Deck.card_y)
