extends Control

func _ready() -> void:
	GameManager.UIOverlay.hide_ui()

func _on_main_menu_button_pressed() -> void:
	GameManager.Map.queue_free()
	SceneManager.change_scene("res://scenes/main_menu.tscn")
