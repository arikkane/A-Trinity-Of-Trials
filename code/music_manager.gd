extends Node

var current_track: String = ""

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var tracks := {
	"main_menu": preload("res://Audio/HallofKing.ogg"),
	"combat": preload("res://Audio/Ghost.ogg"),
	"shop": preload("res://Audio/InCastle.ogg"),
	"event": preload("res://Audio/CursedVillage.ogg"),
	"map": preload("res://Audio/StrangeFarm.ogg")
}

func _ready() -> void:
	add_child(music_player)
	music_player.bus = "Music"
	music_player.volume_db = -8
	music_player.finished.connect(_on_music_finished)

func play_track(track_name: String) -> void:
	if not tracks.has(track_name):
		push_error("MusicManager: track not found: " + track_name)
		return

	if current_track == track_name and music_player.playing:
		return

	current_track = track_name
	music_player.stream = tracks[track_name]
	music_player.play()

func stop_music() -> void:
	music_player.stop()
	current_track = ""

func _on_music_finished() -> void:
	if current_track != "" and tracks.has(current_track):
		music_player.stream = tracks[current_track]
		music_player.play()
