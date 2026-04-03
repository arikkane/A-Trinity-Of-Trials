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

# All cards loaded from JSON
var card_data = {}

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
	load_cards()
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

#Function for grabbing card info and putting it into the user's deck.
	for i in len(deck_data[className]):
		var count = int(len(deck_data[className]))
		print("card no of " + className + ": " + str(i))
		#deck_data[className][i] refers to the ID of a card in the current deck.
		#card_data["cards"][deck_data[className][i]] refers to the card that the ID of the card in the deck is pointing to.
		
		print("card ID: " + str(deck_data[className][i]))
		print(card_data["cards"][deck_data[className][i]].get("name", 0))
		
		var currentCard = card_data["cards"][deck_data[className][i]]
		
		var card = create_card(
			currentCard.get("type", "Damage"),
			currentCard.get("damage", 0),
			currentCard.get("block", 0),
			currentCard.get("heal", 0),
			currentCard.get("name", "Unnamed Card")
		)
		
		#Checks to see if the card is a draw boost
		if currentCard.has("draw"):
			card.draw = int(currentCard["draw"])
		
		#adds the card to the deck, sets its ID
		full_deck.append(card)
		full_deck[i].id = deck_data[className][i]
		
		


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
# Load CARDS from JSON file (loads all existing cards within the game)
# ----------------------------
func load_cards():
	card_data = JsonLoader.load_cards()

# ----------------------------
# Load decks from JSON file
# ----------------------------
func load_decks():
	deck_data = JsonLoader.load_decks()
