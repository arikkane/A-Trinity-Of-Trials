extends Node

var initialized = false

func _ready() -> void:
	if initialized:
		print("⚠️ Main already initialized — skipping")
		return
	
	initialized = true
	
	print("Main scene loaded")

	SceneManager.SceneContainer = $"SceneContainer"
	GameManager.UIOverlay = $"UIOverlay"
	$"UIOverlay".hide_ui()
	GameManager.Main = self
	
	SceneManager.change_scene("res://scenes/ClassSelection.tscn")
