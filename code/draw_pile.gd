extends TextureRect

var card_array: Array[Control]

func _ready() -> void:
	custom_minimum_size = Vector2(128,192)
	global_position = Vector2(32, 760)

func add_card(card:Control):
	card_array.append(card)
	add_child(card)

func remove_card(card:Control):
	card_array.erase(card)
	remove_child(card)
