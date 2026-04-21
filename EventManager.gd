extends Node

var current_event_data: EventData = null
var in_event: bool = false

func _ready() -> void:
	if not EventBus.is_connected("event_started", Callable(self, "_on_event_started")):
		EventBus.connect("event_started", Callable(self, "_on_event_started"))

func _on_event_started(data: EventData) -> void:
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
	SceneManager.SceneTransition.detransition_scene()
	if not in_event:
		return
	
	print("EventManager: finishing event")

	in_event = false
	current_event_data = null
	SceneManager.change_scene("res://scenes/map.tscn")
