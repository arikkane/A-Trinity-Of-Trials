extends Node

func _ready() -> void:
	print("Main scene loaded")
	#initializes player variables, (max player hp, cards drawn per turn)
	GameManager.init_player_variables(100,6)
	SceneManager.change_scene("res://scenes/combat.tscn")
