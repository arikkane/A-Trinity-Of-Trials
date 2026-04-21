extends Node

var room_data: CombatData

func _ready():
	$"NextRoomButton".pressed.connect(_on_button_pressed)

func init_room_data(data: CombatData):
	room_data = data
	print_room_data()

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Min Gold: " + str(room_data.min_gold))
	print("Max Gold: " + str(room_data.max_gold))
	print("Enemies: ") 
	for enemy in room_data.enemies:
		print("  " + enemy)

func give_gold():
	print("Acquired Gold: " + str(randi_range(room_data.min_gold, room_data.max_gold)))

func _on_button_pressed():
	print("button pressed")
	give_gold()
	GameManager.encounter_complete()
