extends Node

func _ready() -> void:
	GameManager.Deck.combat_start()
	GameManager.Deck.draw_cards()
	GameManager.Deck.combat_start()

#initalize enemy function

#handle player turn functionality
