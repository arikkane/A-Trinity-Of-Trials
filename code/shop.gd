extends Node

var room_data
var cards: Array[Control]

func _ready():
	$"NextRoomButton".pressed.connect(_on_button_pressed)
	cards = init_card_data()

func init_room_data(data: ShopData):
	room_data = data
	print_room_data()

func init_card_data():
	var card_pool: Array[int] = {}
	for card in GameManager.Deck.card_data["cards"][GameManager.PlayerClass]:
		card_pool.append(card.get("id"));

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Card Pool: " + room_data.card_pool)
	print("Remove Card Cost: " + str(room_data.remove_card_cost))

func _on_button_pressed():
	print("button pressed")
	GameManager.encounter_complete()
