extends Node

#sfx list
var sounds = {
	"select": preload("res://assets/Sounds/select1.wav"),
	"select2": preload("res://assets/Sounds/select2.wav"),
	"cancel": preload("res://assets/Sounds/select3.wav"),
	"buzzer": preload("res://assets/Sounds/buzzer1.wav"),
	"notice": preload("res://assets/Sounds/notice.wav"),
	"stab": preload("res://assets/Sounds/stab.wav"),
	"swordslash": preload("res://assets/Sounds/swordslash.wav"),
	"swordblow": preload("res://assets/Sounds/swordblow.wav"),
	"punch": preload("res://assets/Sounds/punch.wav"),
	"punch2": preload("res://assets/Sounds/punch2.wav"),
	"heal": preload("res://assets/Sounds/heal.wav"),
	"crumble": preload("res://assets/Sounds/crumble.wav"),
	"scrape": preload("res://assets/Sounds/scrape.wav")
}

#This is the audio manager.
@onready var music_player = AudioStreamPlayer.new()
var volume = -10

func _ready():
	add_child(music_player)

#Play a sound from the list.
#use case: AudioManager.play_sfx(preload("res://assets/Sounds/test.wav"))
func play_sfx(name: String):
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	if sounds.has(name):
		player.stream = sounds[name]
		player.volume_db = volume
		player.play()
		player.finished.connect(player.queue_free)
	else:
		print("Invalid audio played.")
		player.queue_free

#Play a sound by loading its path rather than by a predetermined string
#use case: AudioManager.play_sfx(preload("res://assets/Sounds/test.wav"))
func play_sfx_path(sound: AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.volume_db = volume
	player.play()
	player.finished.connect(player.queue_free)
