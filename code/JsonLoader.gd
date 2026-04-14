extends Node

#---This function is responsible for loading json files from the game's /Data/ directory.--

# ----------------------------
# Load CARDS from JSON file (loads all existing cards within the game)
# ----------------------------
func load_cards():
	var file = FileAccess.open("res://data/cards.json", FileAccess.READ)
	if not file:
		push_error("Could not open cards.json")
		return
	
	var text = file.get_as_text()
	var parsed = JSON.parse_string(text)
	
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	else:
		push_error("JSON parse failed: " + str(parsed))

# ----------------------------
# Load decks from JSON file
# ----------------------------
func load_decks():
	var file = FileAccess.open("res://data/Starter_Decks.json", FileAccess.READ)
	if not file:
		push_error("Could not open Starter_Decks.json")
		return

	var text = file.get_as_text()
	var parsed = JSON.parse_string(text)
	
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	else:
		push_error("JSON parse failed: " + str(parsed))
