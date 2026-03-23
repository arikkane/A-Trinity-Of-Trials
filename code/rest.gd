extends Node

var room_data

func _ready():
	$"HealButton".pressed.connect(_on_heal_button_pressed)
	$"GoldButton".pressed.connect(_on_gold_button_pressed)

func init_room_data(data: RestData):
	room_data = data
	$"HealButton".text = "Heal " + str(int(GameManager.PlayerMaxHP * room_data.heal_percentage)) + " health"
	$"GoldButton".text = "Take " + str(room_data.min_gold) + "-" + str(room_data.max_gold) + " gold"
	print_room_data()

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Heal Percentage: " + str(room_data.heal_percentage))

func _on_heal_button_pressed():
	print("heal button pressed")
	print("before PlayerHP = " + str(GameManager.PlayerHP))
	GameManager.PlayerHP += int(GameManager.PlayerMaxHP * room_data.heal_percentage)
	GameManager.PlayerHP = clamp(GameManager.PlayerHP, 0, GameManager.PlayerMaxHP)
	print("after PlayerHP = " + str(GameManager.PlayerHP))
	GameManager.encounter_complete()

func _on_gold_button_pressed():
	print("gold button pressed")
	print("before PlayerGold = " + str(GameManager.PlayerGold))
	GameManager.PlayerGold += randi_range(room_data.min_gold, room_data.max_gold)
	print("after PlayerGold = " + str(GameManager.PlayerGold))
	GameManager.encounter_complete()
