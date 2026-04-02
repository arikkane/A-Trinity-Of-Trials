extends Node

#main node for the game, loads on startup of the game
var map_scene: PackedScene = preload("res://scenes/map.tscn")
var map

func _ready() -> void:
	print("Main scene loaded")
	#initializes player variables, (max player hp, cards drawn per turn)\
	SceneManager.SceneContainer = $"SceneContainer"
	GameManager.UIOverlay = $"UIOverlay"
	$"UIOverlay".hide_ui()
	GameManager.init_player_variables(100,6)
	GameManager.Main = self
	SceneManager.change_scene("res://scenes/ClassSelection.tscn")
