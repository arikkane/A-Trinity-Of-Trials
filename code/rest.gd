extends Node

var room_data

func _ready():
	init_room_data(EventManager.current_event_data)
	init_player_sprite()
	$"HealButton".pressed.connect(_on_heal_button_pressed)
	$"GoldButton".pressed.connect(_on_gold_button_pressed)

func init_room_data(data: RestData):
	room_data = data
	$"HealButton".text = "Heal " + str(int(GameManager.PlayerMaxHP * room_data.heal_percentage)) + " health"
	$"GoldButton".text = "Take " + str(room_data.min_gold) + "-" + str(room_data.max_gold) + " gold"
	print_room_data()

func init_player_sprite():
	match GameManager.current_class:
		GameManager.PlayerClass.GUNDAM:
			$"PlayerSprite".texture = load("res://sprites/ArmorChar.png")
			$"PlayerSprite".scale = Vector2(0.75, 0.75)
			$"PlayerSprite".global_position = Vector2(470, 593)
		GameManager.PlayerClass.HEXTECHMAGE:
			$"PlayerSprite".texture = load("res://sprites/magechar.png")
			$"PlayerSprite".scale = Vector2(2.5, 2.5)
			$"PlayerSprite".global_position = Vector2(461, 595)
		GameManager.PlayerClass.CREATURE:
			$"PlayerSprite".texture = load("res://sprites/voidchar (2).png")
			$"PlayerSprite".scale = Vector2(2.0, 2.0)
			$"PlayerSprite".global_position = Vector2(477, 584)

func print_room_data():
	print("ID: " + room_data.id)
	print("Gen Weight: " + str(room_data.gen_weight))
	print("Heal Percentage: " + str(room_data.heal_percentage))

func _on_heal_button_pressed():
	print("heal button pressed")
	AudioManager.play_sfx("heal")
	print("before PlayerHP = " + str(GameManager.PlayerHP))
	GameManager.PlayerHP += int(GameManager.PlayerMaxHP * room_data.heal_percentage)
	GameManager.PlayerHP = clamp(GameManager.PlayerHP, 0, GameManager.PlayerMaxHP)
	GameManager.UIOverlay.update_health()
	print("after PlayerHP = " + str(GameManager.PlayerHP))
	await SceneManager.SceneTransition.transition_scene("diagonal_sweep")
	EventManager.finish_event()

func _on_gold_button_pressed():
	print("gold button pressed")
	AudioManager.play_sfx("coinbag")
	print("before PlayerGold = " + str(GameManager.PlayerGold))
	GameManager.PlayerGold += randi_range(room_data.min_gold, room_data.max_gold)
	GameManager.UIOverlay.update_gold()
	print("after PlayerGold = " + str(GameManager.PlayerGold))
	await SceneManager.SceneTransition.transition_scene("diagonal_sweep")
	EventManager.finish_event()
