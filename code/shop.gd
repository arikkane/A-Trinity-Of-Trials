extends Node

#change this to change amount of cards being sold. should dynamically change alignments
var card_per_shelf = 4
var card_for_sale_scene: PackedScene = preload("res://scenes/card_for_sale.tscn")
#holds the RoomData/ShopData resource instance
var room_data
#holds the cards_for_sale instances
var cards: Array[Control]
#holds the size of the container for the top and bottom shelf
var card_stock_size_x = 1142
var card_separation = 0
var can_afford_remove = true
var remove_used = false

func _ready():
	init_card_data()
	if EventManager.current_event_data != null:
		init_room_data(EventManager.current_event_data)
#----------------------------------------------------------
# This function places the reference to the ShopData object
# into the designated variable
#----------------------------------------------------------
func init_room_data(data: ShopData):
	room_data = data
	check_if_remove_card_affordable()

#------------------------------------------------
# This function initializes the data and textures
# for the cards that will be sold in the shop
#------------------------------------------------
func init_card_data():
	#id of cards that can be picked from to be sold
	var card_pool: Array[int]
	#adds every card for the playable class into the card pool
	for card in GameManager.Deck.card_data["cards"]:
		if card.get("class", -1) == GameManager.current_class:
			card_pool.append(card.get("id"))
	#Appending Super Heal Pulse and Bomb for DEMONSTRATION PURPOSES, these will be removed later.
	card_pool.append(10)
	card_pool.append(14)
	if card_pool.is_empty():
		push_error("Shop: no cards found for class " + str(GameManager.current_class))
		return
	#generating each card being sold
	for i in range(card_per_shelf*2):
		#picks the card that will be sold from the card pool
		var card_id = randi_range(0, card_pool.size()-1)
		#gets the cards data based on the generated id
		var card = GameManager.Deck.card_data["cards"][card_pool[card_id]]
		#creates the card object
		var card_object = card_for_sale_scene.instantiate()
		card_object.card_data = GameManager.Deck.create_card(card.type, card.damage, card.block, card.heal, card.name)
		card_object.update_sprite()
		card_object.generate_price(GameManager.Deck.card_data["cards"][card_pool[card_id]].get("base_price", 60))
		#connects the cards input handling signal
		card_object.card_purchased.connect(_on_card_purchased)
		cards.append(card_object)
		if (i+1) <= (card_per_shelf):
			$"TopShelfContainer".add_child(card_object)
		else:
			$"BottomShelfContainer".add_child(card_object)
	#calculates the separation needed to align the cards on the shelves evenly
	var card_size_x = cards[0].get_node("CardTexture").size.x
	card_separation = (card_stock_size_x-(card_size_x*card_per_shelf))/(card_per_shelf-1)+card_size_x
	$"TopShelfContainer".add_theme_constant_override("separation", int(card_separation))
	$"BottomShelfContainer".add_theme_constant_override("separation", int(card_separation))
	for card in cards:
		card.update_labels()

#-----------------------------------
# This function checks if the player
# has enough gold to afford removing
# a card from their deck
#-----------------------------------
func check_if_remove_card_affordable():
	if not remove_used:
		if GameManager.PlayerGold >= room_data.remove_card_cost:
			$"RemoveCardButton/Price".add_theme_color_override("default_color", "#00a300")
			can_afford_remove = true
		else:
			$"RemoveCardButton/Price".add_theme_color_override("default_color", "#dd2400")
			can_afford_remove = false

#-----------------------------Event Handling-----------------------------
func _on_card_purchased():
	AudioManager.play_sfx("purchase")
	for card in cards:
		if not card.purchased:
			card.check_if_affordable()
			check_if_remove_card_affordable()

func _on_remove_card_button_pressed():
	if can_afford_remove and not remove_used:
		GameManager.DeckDisplayUI.pay_for_removal.connect(_on_card_removed)
		GameManager.DeckDisplayUI.init_card_removal()

func _on_card_removed():
	GameManager.PlayerGold -= room_data.remove_card_cost
	GameManager.UIOverlay.update_gold()
	GameManager.DeckDisplayUI.pay_for_removal.disconnect(_on_card_removed)
	remove_used = true
	AudioManager.play_sfx("purchase")
	$"RemoveCardButton/Price".visible = false
	$"RemoveCardButton/GoldIcon".visible = false
	$"RemoveCardButton".text = "SOLD OUT"
	$"RemoveCardButton".disabled = true

func _on_leave_button_pressed():
	print("button pressed")
	AudioManager.play_sfx("store_enter")
	await SceneManager.SceneTransition.transition_scene()
	EventManager.finish_event()

#-----------------------------Debug Functions-----------------------------
func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Card Pool: " + room_data.card_pool)
	print("Remove Card Cost: " + str(room_data.remove_card_cost))
