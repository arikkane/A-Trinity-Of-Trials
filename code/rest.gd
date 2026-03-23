extends Node

var room_data

func _ready():
	$"NextRoomButton".pressed.connect(_on_button_pressed)

func init_room_data(data: RestData):
	room_data = data
	print_room_data()

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Heal Percentage: " + str(room_data.heal_percentage))

func _on_button_pressed():
	print("button pressed")
	GameManager.encounter_complete()
