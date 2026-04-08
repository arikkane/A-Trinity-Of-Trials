extends TextureRect

#handles the map button in the UI overlay being clicked
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			#if the map is already open and the deck display is not open
			if GameManager.Map.visible and not GameManager.DeckDisplayUI.visible:
				#if the map is locked, i.e. input is not allowed because the current room encounter is not finished
				if GameManager.Map.map_lock:
					GameManager.Map.hide_map()
			elif GameManager.Map.visible and GameManager.DeckDisplayUI.visible and not GameManager.DeckDisplayUI.remove_selecting:
				GameManager.DeckDisplayUI.hide()
			else:
				if not GameManager.DeckDisplayUI.remove_selecting:
					GameManager.Map.show_map()
					#if the deck display is open, hides it as it appears over the map
					if GameManager.DeckDisplayUI.visible:
						GameManager.DeckDisplayUI.hide()

func _on_mouse_entered():
	modulate = Color("#824800")

func _on_mouse_exited():
	modulate = Color("#5f3300")
