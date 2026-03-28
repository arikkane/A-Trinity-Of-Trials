extends Control

# Holds all cards in the player's deck
var full_deck: Array = []

var card_scene: PackedScene = preload("res://scenes/card.tscn")

# Card layout variables
var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

# Deck data loaded from JSON
var deck_data = {}

# ----------------------------
# Debug function
# ----------------------------
func display_full_deck():
	for i in range(full_deck.size()):
		print("Card #" + str(i) + ": " + str(full_deck[i].card_name))

# ----------------------------
# Initialize deck from JSON
# ----------------------------
func init_cards():
	full_deck.clear()
	load_decks()
	
	var className = ""
	match GameManager.current_class:
		GameManager.PlayerClass.GUNDAM:
			className = "GUNDAM"
		GameManager.PlayerClass.HEXTECHMAGE:
			className = "HEXTECHMAGE"
		GameManager.PlayerClass.CREATURE:
			className = "CREATURE"

	if not deck_data.has(className):
		push_error("Class not found in JSON: " + className)
		return

	for card_info in deck_data[className]:
		var count = int(card_info.get("count", 1))
		for i in range(count):
			var card = create_card(
				card_info.get("type", "Damage"),
				card_info.get("damage", 0),
				card_info.get("block", 0),
				card_info.get("heal", 0),
				card_info.get("name", "Unnamed Card")
			)
			# Optional draw effect
			if card_info.has("draw"):
				card.draw = int(card_info["draw"])
			full_deck.append(card)
	
	#sets unique id's for now
	for i in range(full_deck.size()):
		full_deck[i].id = i

# ----------------------------
# Card creation helper
# ----------------------------
func create_card(card_type, damage, block, heal, card_name_str):
	var card_data_resource = load("res://code/card_data.gd")
	#does not load the scene for the card, card.scene.instantiate() should be loaded whenever the card ui is needed
	var card = card_data_resource.new()

	card.type = card_type
	card.damage = damage
	card.block = block
	card.heal = heal
	#card.card_name = card_name_str
	card.name = card_name_str  # assign node name to avoid confusion

	# Auto-generate description if none provided
	if damage > 0:
		card.description = "Deals " + str(damage) + " damage"
	elif block > 0:
		card.description = "Gain " + str(block) + " block"
	elif heal > 0:
		card.description = "Heal " + str(heal)
	else:
		card.description = card_name_str
	
	return card

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
		deck_data = parsed
	else:
		push_error("JSON parse failed: " + str(parsed))
