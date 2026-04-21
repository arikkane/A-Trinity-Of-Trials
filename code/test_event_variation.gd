extends Control

var room_data: EventData

#---Text and Text Animation Variables--
const TEXT_ANIMATION_SPEED : int = 20
var animate_text : bool = false
var current_visible_characters : int = 0 
signal text_animation_done

func _ready() -> void:
	$IntroPanel/Proceed.pressed.connect(_on_proceed_button_pressed)
	$IntroPanel/GoAround.pressed.connect(_on_go_around_button_pressed)
	$EventPanel/NextRoomButton.pressed.connect(_on_next_room_button_pressed)

	room_data = EventManager.current_event_data

	if room_data == null:
		push_error("Event room loaded without event data.")
		return

	$IntroPanel.visible = false
	$EventPanel.visible = false
	$IntroPanel/IntroLabel.text = "You find a small clearing with a grotto."
	
	await show_text("You find a small clearing with a grotto.")
	$IntroPanel.visible = true

#Animate text function
func show_text(display_text):
	if GameManager.AnimatedText == true:
		current_visible_characters = 0
		$TextContainer/Info.visible_characters = 0
		$TextContainer/Info.text = display_text
		animate_text = true
	
		await text_animation_done
	else:
		$TextContainer/Info.text = display_text
	return

func _on_proceed_button_pressed() -> void:
	$IntroPanel.visible = false
	#$EventPanel.visible = true
	setup_event()

func _on_go_around_button_pressed() -> void:
	print("Player chose to go around.")
	AudioManager.play_sfx("nope")
	SceneManager.SceneTransition.transition_scene("horizontal_wipe")
	EventManager.finish_event()

func setup_event() -> void:
	match room_data.type:
		EventData.EventType.TREASURE:
			AudioManager.play_sfx("coinbag")
			$EventPanel/NextRoomButton.text = "Take " + str(room_data.reward) + " Gold"

		EventData.EventType.TRAP:
			AudioManager.play_sfx("scream")
			$EventPanel/NextRoomButton.text = "Take " + str(room_data.damage) + " Damage"

		EventData.EventType.HEAL:
			AudioManager.play_sfx("heal")
			$EventPanel/NextRoomButton.text = "Heal +" + str(room_data.reward) + " HP"

		EventData.EventType.CHOICE_CARD:
			$EventPanel/NextRoomButton.text = "Choose a Card"
	
	await show_text(room_data.description)
	$EventPanel.visible = true

func _on_next_room_button_pressed() -> void:
	apply_event_effect()
	await SceneManager.SceneTransition.transition_scene("horizontal_wipe")
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

func _process(delta):
	if GameManager.AnimatedText == true:
		if animate_text == true:
			if $TextContainer/Info.visible_ratio < 1:
				$TextContainer/Info.visible_ratio += (1.0/$TextContainer/Info.text.length()) * (TEXT_ANIMATION_SPEED * delta)
				current_visible_characters = $TextContainer/Info.visible_characters
				AudioManager.play_sfx("textblip")
			else:
				animate_text = false
				text_animation_done.emit()
	else:
		$TextContainer/Info.visible_ratio = $TextContainer/Info.text.length()
