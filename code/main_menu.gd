extends Node

func _ready() -> void:
	$"RichTextLabel".push_font_size(128)
	$"RichTextLabel".global_position = Vector2(900, 200)
