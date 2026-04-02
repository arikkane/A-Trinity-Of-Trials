extends TextureRect

#handles the deck button of the UI overlay being pressed
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			#hides the deck display if it is visible, shows it if it isn't
			if GameManager.DeckDisplayUI.visible:
				GameManager.DeckDisplayUI.hide()
			else:
				GameManager.DeckDisplayUI.show_deck()
				
