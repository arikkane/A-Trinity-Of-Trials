extends Node


# Sound Effects
var sounds = {
	"textblip": preload("res://assets/Sounds/blip.wav"),
	"menuclick": preload("res://assets/Sounds/menuclick1.wav"),
	"menuclick2": preload("res://assets/Sounds/menuclick2.wav"),
	"scroll": preload("res://assets/Sounds/scroll.wav"),
	"select": preload("res://assets/Sounds/select1.wav"),
	"select2": preload("res://assets/Sounds/select2.wav"),
	"cancel": preload("res://assets/Sounds/select3.wav"),
	"buzzer": preload("res://assets/Sounds/buzzer1.wav"),
	"store_enter": preload("res://assets/Sounds/store-enter.wav"),
	"purchase": preload("res://assets/Sounds/purchase.wav"),
	"grass_rustle": preload("res://assets/Sounds/grass-rustle.wav"),
	"coinbag": preload("res://assets/Sounds/coinbag.wav"),
	"scream": preload("res://assets/Sounds/wilhelm-scream.wav"),
	"nope": preload("res://assets/Sounds/nope.wav"),
	"victory": preload("res://assets/Sounds/victory-sting.wav"),
	"defeat": preload("res://assets/Sounds/defeat.wav"),
	"notice": preload("res://assets/Sounds/notice.wav"),
	"sword_shing": preload("res://assets/Sounds/sword_shing.wav"),
	"stab": preload("res://assets/Sounds/stab.wav"),
	"swordslash": preload("res://assets/Sounds/swordslash.wav"),
	"swordblow": preload("res://assets/Sounds/swordblow.wav"),
	"punch": preload("res://assets/Sounds/punch.wav"),
	"punch2": preload("res://assets/Sounds/punch2.wav"),
	"heal": preload("res://assets/Sounds/heal.wav"),
	"crumble": preload("res://assets/Sounds/crumble.wav"),
	"scrape": preload("res://assets/Sounds/scrape.wav"),
	"explosion": preload("res://assets/Sounds/explosion.wav")
}


# Music Tracks
var music_tracks = {
	"main_menu": preload("res://Audio/HallofKing.ogg"),
	"combat": preload("res://Audio/Ghost.ogg"),
	"shop": preload("res://Audio/InCastle.ogg"),
	"event": preload("res://Audio/CursedVillage.ogg"),
	"map": preload("res://Audio/StrangeFarm.ogg"),
	"boss": preload("res://Audio/BossMusic.ogg")
}
#This is the audio manager.
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var music_volume := -10.0
var sfx_volume := -10.0
var current_music_name := ""

func _ready() -> void:
	add_child(music_player)
	

# Music 
func play_music(sound: AudioStream) -> void:
	if sound == null:
		push_error("AudioManager: Tried to play null music stream.")
		return

	music_player.stream = sound
	if music_player.stream is AudioStreamOggVorbis:
		music_player.stream.loop = true
	#music_player.volume_db = music_volume
	music_player.volume_db = -10.0
	music_player.play()

func play_music_track(track_name: String) -> void:
	if not music_tracks.has(track_name):
		push_error("AudioManager: Unknown music track: " + track_name)
		return

	if current_music_name == track_name and music_player.playing:
		return

	current_music_name = track_name
	play_music(music_tracks[track_name])

func stop_music() -> void:
	music_player.stop()
	current_music_name = ""
	music_player.pitch_scale = 1.0

func set_music_pitch(pitch: float) -> void:
	var t = create_tween()
	t.tween_property(music_player, "pitch_scale", pitch, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func set_music_volume(volume_db: float) -> void:
	music_volume = volume_db
	music_player.volume_db = music_volume

# Optional fade
func fade_to_music(track_name: String, fade_time: float = 0.5) -> void:
	if not music_tracks.has(track_name):
		push_error("AudioManager: Unknown music track: " + track_name)
		return

	if current_music_name == track_name and music_player.playing:
		return

	var tween_out = create_tween()
	tween_out.tween_property(music_player, "volume_db", -40.0, fade_time)
	await tween_out.finished

	current_music_name = track_name
	music_player.stop()
	music_player.stream = music_tracks[track_name]
	music_player.volume_db = -40.0
	music_player.play()

	var tween_in = create_tween()
	tween_in.tween_property(music_player, "volume_db", music_volume, fade_time)

# SFX
func play_sfx(name: String) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	

	if sounds.has(name):
		player.stream = sounds[name]
		player.volume_db = sfx_volume
		player.play()
		player.finished.connect(player.queue_free)
	else:
		print("Invalid audio played: ", name)
		player.queue_free()

func play_sfx_path(sound: AudioStream) -> void:
	if sound == null:
		push_error("AudioManager: Tried to play null SFX stream.")
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = sound
	player.volume_db = sfx_volume
	player.play()
	player.finished.connect(player.queue_free)

func set_sfx_volume(volume_db: float) -> void:
	sfx_volume = volume_db
	

func set_master_volume(value: float) -> void:
	music_volume = linear_to_db(value)
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, music_volume)
