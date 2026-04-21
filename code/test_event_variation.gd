extends Control

var room_data: EventData

func _ready() -> void:
	$IntroPanel/Proceed.pressed.connect(_on_proceed_button_pressed)
	$IntroPanel/GoAround.pressed.connect(_on_go_around_button_pressed)
	$EventPanel/NextRoomButton.pressed.connect(_on_next_room_button_pressed)

	room_data = EventManager.current_event_data

	if room_data == null:
		push_error("Event room loaded without event data.")
		return

	$IntroPanel.visible = true
	$EventPanel.visible = false
	$IntroPanel/IntroLabel.text = "You find a small clearing with a grotto."

func _on_proceed_button_pressed() -> void:
	$IntroPanel.visible = false
	$EventPanel.visible = true
	setup_event()

func _on_go_around_button_pressed() -> void:
	print("Player chose to go around.")
	EventManager.finish_event()

func setup_event() -> void:
	$EventPanel/DescriptionLabel.text = room_data.description

	match room_data.type:
		EventData.EventType.TREASURE:
			$EventPanel/NextRoomButton.text = "Take " + str(room_data.reward) + " Gold"

		EventData.EventType.TRAP:
			$EventPanel/NextRoomButton.text = "Take " + str(room_data.damage) + " Damage"

		EventData.EventType.HEAL:
			$EventPanel/NextRoomButton.text = "Heal +" + str(room_data.reward) + " HP"

		EventData.EventType.CHOICE_CARD:
			$EventPanel/NextRoomButton.text = "Choose a Card"

func _on_next_room_button_pressed() -> void:
	apply_event_effect()
	EventManager.finish_event()

func apply_event_effect() -> void:
	match room_data.type:
		EventData.EventType.TREASURE:
			GameManager.PlayerGold += room_data.reward
			print("Gained gold: ", room_data.reward)

		EventData.EventType.TRAP:
			GameManager.PlayerHP -= room_data.damage
			GameManager.PlayerHP = max(GameManager.PlayerHP, 0)
			print("Took damage: ", room_data.damage)

		EventData.EventType.HEAL:
			GameManager.PlayerHP += room_data.reward
			GameManager.PlayerHP = min(GameManager.PlayerHP, GameManager.PlayerMaxHP)
			print("Healed: ", room_data.reward)

		EventData.EventType.CHOICE_CARD:
			print("TODO: open card choice UI")

	if GameManager.UIOverlay != null:
		GameManager.UIOverlay.update_health()
		GameManager.UIOverlay.update_gold()
