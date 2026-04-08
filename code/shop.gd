extends Node

#change this to change amount of cards being sold. should dynamically change alignments
var card_per_shelf = 4
var card_for_sale_scene: PackedScene = preload("res://scenes/card_for_sale.tscn")
var room_data
var cards: Array[Control]
var card_stock_size_x = 1142
var card_separation = 0

func _ready():
	$"NextRoomButton".pressed.connect(_on_button_pressed)
	init_card_data()

func init_room_data(data: ShopData):
	room_data = data
	print_room_data()

func init_card_data():
	var card_pool: Array[int]
	for card in GameManager.Deck.card_data["cards"]:
		if card.class == GameManager.current_class:
			card_pool.append(card.get("id"))
	for i in range(card_per_shelf*2):
		var card_id = randi_range(0, card_pool.size()-1)
		var card = GameManager.Deck.card_data["cards"][card_id]
		var card_object = card_for_sale_scene.instantiate()
		card_object.card_data = GameManager.Deck.create_card(card.id, card.type, card.damage, card.block, card.heal, card.name)
		card_object.generate_price(GameManager.Deck.card_data["cards"][card_id].get("base_price", 60))
		card_object.card_purchased.connect(_on_card_purchased)
		cards.append(card_object)
		if (i+1) <= (card_per_shelf):
			$"TopShelfContainer".add_child(card_object)
		else:
			$"BottomShelfContainer".add_child(card_object)
	var card_size_x = cards[0].get_node("CardTexture").size.x
	card_separation = (card_stock_size_x-(card_size_x*card_per_shelf))/(card_per_shelf-1)+card_size_x
	$"TopShelfContainer".add_theme_constant_override("separation", int(card_separation))
	$"BottomShelfContainer".add_theme_constant_override("separation", int(card_separation))
	for card in cards:
		card.update_labels()

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Card Pool: " + room_data.card_pool)
	print("Remove Card Cost: " + str(room_data.remove_card_cost))

func _on_card_purchased():
	for card in cards:
		if not card.purchased:
			card.check_if_affordable()

func _on_button_pressed():
	print("button pressed")
	GameManager.encounter_complete()
	
