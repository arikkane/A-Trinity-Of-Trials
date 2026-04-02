extends TextureRect

#handles the map button in the UI overlay being clicked
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			#if the map is already open
			if GameManager.Map.visible:
				#if the map is locked, i.e. input is not allowed because the current room encounter is not finished
				if GameManager.Map.map_lock:
					GameManager.Map.hide_map()
			else:
				GameManager.Map.show_map()
				#if the deck display is open, hides it as it appears over the map
				if GameManager.DeckDisplayUI.visible:
					GameManager.DeckDisplayUI.hide()
