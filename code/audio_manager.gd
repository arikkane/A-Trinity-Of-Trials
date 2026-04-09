extends Node

#This is the audio manager.
@onready var music_player = AudioStreamPlayer.new()
var volume = 100

func _ready():
	add_child(music_player)

#use case: AudioManager.play_sfx(preload("res://assets/Sounds/test.wav"))
func play_sfx(sound: AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.play()
	player.finished.connect(player.queue_free)
