extends TextureRect

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if GameManager.DeckDisplayUI.visible:
				GameManager.DeckDisplayUI.hide()
			else:
				GameManager.DeckDisplayUI.show()
