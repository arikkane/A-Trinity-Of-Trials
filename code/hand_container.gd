extends Control

var card_array: Array[Control]

func add_card(card:Control):
	card_array.append(card)
	add_child(card)
	update_card_positions()

func remove_card(card:Control):
	card_array.erase(card)
	remove_child(card)
	update_card_positions()

func update_card_positions():
	if not card_array.is_empty():
		var card_spacing = 0
		#increases the overlap by 16 pixels for every card over 6 in the players hand
		if card_array.size() > 6:
			card_spacing += (card_array.size()-6)*-16
		else:
			card_spacing = 0
		var hand_width = (card_array.size() * get_parent().card_width) + ((card_array.size()-1) * card_spacing)
		#x coordinate of the far left side of the hand node
		var start_x = (get_tree().root.get_visible_rect().size.x - hand_width)/2
		for i in range(card_array.size()):
			card_array[i].global_position = Vector2(start_x + i * (get_parent().card_width+card_spacing), get_parent().card_y)
