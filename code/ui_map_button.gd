extends TextureRect

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if GameManager.Map.visible:
				if GameManager.Map.map_lock:
					GameManager.Map.hide_map()
			else:
				GameManager.Map.show_map()
				if GameManager.DeckDisplayUI.visible:
					GameManager.DeckDisplayUI.hide()
