extends TextureRect

var card_array: Array[Control]

func _ready() -> void:
	custom_minimum_size = Vector2(128,192)
	global_position = Vector2(get_viewport().size.x - 224, 760)
