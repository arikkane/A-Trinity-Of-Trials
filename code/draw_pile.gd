extends TextureRect

var card_array: Array[Control]

#sets size and position of sprite
func set_transforms():
	print("DrawPile: in set_transforms()")
	custom_minimum_size = Vector2(get_parent().card_width, get_parent().card_height)
	global_position = Vector2(get_parent().side_margin, get_parent().card_y)

func add_card(card:Control):
	card_array.append(card)
	add_child(card)

func remove_card(card:Control):
	card_array.erase(card)
	remove_child(card)

func display_cards():
	print("In Draw Pile: ")
	for i in range(card_array.size()):
		print("  Card #" + str(i) + ": " + str(card_array[i].card_id))
