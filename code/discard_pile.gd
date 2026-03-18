extends TextureRect

var card_array: Array[Control]

#sets size and position of sprite
func set_transforms():
	print("DiscardPile: in set_transforms()")
	custom_minimum_size = Vector2(get_parent().card_width, get_parent().card_height)
	global_position = Vector2(get_tree().root.get_visible_rect().size.x - get_parent().card_width - get_parent().side_margin, get_parent().card_y)
