extends Node

const SAVE_PATH = "user://run_save.json"

func save_run_deck(deck: Node) -> void:
	var card_ids: Array = []
	for card in deck.full_deck:
		card_ids.append(card.id)

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"deck": card_ids}))
		file.close()
		print("SaveManager: deck saved (", card_ids.size(), " cards)")
	else:
		push_error("SaveManager: failed to open save file for writing.")

func load_previous_deck() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var result = JSON.parse_string(text)
		if result and result.has("deck"):
			return result["deck"]
	return []

func has_previous_run() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
