extends TextureRect

#handles the deck button of the UI overlay being pressed
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			#hides the deck display if it is visible, shows it if it isn't
			if GameManager.DeckDisplayUI.visible and not GameManager.DeckDisplayUI.remove_selecting:
				GameManager.DeckDisplayUI.hide()
			else:
				GameManager.DeckDisplayUI.update_cards()
				GameManager.DeckDisplayUI.show()

func _on_mouse_entered():
	modulate = Color("#629fff")

func _on_mouse_exited():
	modulate = Color("#3082ff")
