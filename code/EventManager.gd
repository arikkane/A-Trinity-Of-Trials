extends Node

var current_event_data: RoomData = null
var in_event: bool = false

var current_shop_data = null

func _ready() -> void:
	if not EventBus.is_connected("event_started", Callable(self, "_on_event_started")):
		EventBus.connect("event_started", Callable(self, "_on_event_started"))
	if not EventBus.is_connected("shop_started", Callable(self, "_on_shop_started")):
		EventBus.connect("shop_started", Callable(self, "_on_shop_started"))
	if not EventBus.is_connected("rest_started", Callable(self, "_on_rest_started")):
		EventBus.connect("rest_started", Callable(self, "_on_rest_started"))


func _on_event_started(data: EventData) -> void:
	AudioManager.play_music_track("event")
	if in_event:
		print("EventManager: already in event.")
		return

	if data == null:
		push_error("EventManager: event_started received null data.")
		return

	current_event_data = data
	in_event = true

	print("EventManager: starting event ", current_event_data.id)
	SceneManager.change_scene("res://scenes/test_event_variation.tscn")

func finish_event() -> void:
	if not in_event:
		return

	print("EventManager: finishing event")

	in_event = false
	current_event_data = null
	GameManager.encounter_complete()

func _on_shop_started(data) -> void:
	if in_event:
		print("EventManager: already in event.")
		return
	current_shop_data = data
	current_event_data = data
	in_event = true
	AudioManager.play_music_track("shop")
	SceneManager.change_scene("res://scenes/shop.tscn")

func _on_rest_started(data: RestData) -> void:
	if in_event:
		print("EventManager: already in event.")
		return
	AudioManager.play_music_track("event")
	current_event_data = data
	in_event = true
	SceneManager.change_scene("res://scenes/rest.tscn")
