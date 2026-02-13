extends Node

func _ready() -> void:
	$"Player/Deck".combat_start()
	$"Player/Deck".draw_cards()
	$"Player/Deck".combat_start()

#initalize enemy function

#handle player turn functionality
