extends Node

#This script is autoloaded via Project/Globals tab, and contains the player variables and deck node

#=======
# ----------------------------
# Player variables
# ----------------------------


var PlayerMaxHP: int
var PlayerHP: int
var CardsDrawnPerTurn: int
var Deck: Control = null
var PlayerPosition = 0
var PlayerGold = 10
var Main: Node
var UIOverlay: CanvasLayer
var DeckDisplayUI: CanvasLayer
var MapScene: PackedScene = preload("res://scenes/map.tscn")
var Map: Node2D
var MapGridWidth = 8
var MapGridHeight = 6

var popup: CanvasLayer
var VictoryDefeatPopup: PackedScene = preload("res://scenes/victory-defeat.tscn")
var GamePausable: bool = false

#depreciated map save/load variables
#var map_generated: bool = false
#var boss_available: bool = false
#var saved_map_paths: Array = []
#var saved_room_types: Array = []
#var map_selected_path: Array = []
#var map_available_nodes: Array = []

enum PlayerClass {
	GUNDAM,
	HEXTECHMAGE,
	CREATURE
}

var current_class: PlayerClass = PlayerClass.GUNDAM

enum RoomTypes {
	Combat,
	Boss,
	Event,
	Rest,
	Shop
}

# ----------------------------
# Called once when the game starts or player class changes
# ----------------------------
func setup_class(player_class: PlayerClass) -> void:
	current_class = player_class

	match player_class:
		PlayerClass.GUNDAM:
			init_player_variables(120, 4)
		PlayerClass.HEXTECHMAGE:
			init_player_variables(70, 6)
		PlayerClass.CREATURE:
			init_player_variables(100, 5)

	print("Class set to:", current_class, "PlayerMaxHP:", PlayerMaxHP, "PlayerHP:", PlayerHP)
	start_run()

# ----------------------------
# Initialize variables for the selected class
# ----------------------------
func init_player_variables(maxhp: int, cdpt: int) -> void:

	PlayerMaxHP = maxhp
	PlayerHP = maxhp
	CardsDrawnPerTurn = cdpt

	# Only create deck once
	if Deck == null:
		Deck = load("res://scenes/deck.tscn").instantiate()
		add_child(Deck)

	# Rebuild deck every time class is set
	Deck.init_cards()
	
func start_run():
	# Play the transition scene first, THEN load everything
	await SceneManager.SceneTransition.transition_scene()
	
	if DeckDisplayUI == null:
		DeckDisplayUI = load("res://scenes/deck_display.tscn").instantiate()
		Main.add_child(DeckDisplayUI)
	
	Map = MapScene.instantiate()
	Main.add_child(Map)
	Map.show_map()
	
	DeckDisplayUI.update_cards()
	DeckDisplayUI.hide()

	UIOverlay.update_health()
	UIOverlay.update_gold()
	UIOverlay.show_ui()
	UIOverlay.hide_pause()
	GamePausable = true
	
	SceneManager.SceneTransition.detransition_scene() #now play the detransition scene
	AudioManager.play_music_track("map")
	#SceneManager.change_scene("res://scenes/map.tscn")

func encounter_complete():
	AudioManager.play_music_track("map")
	Map.show_map()
	Map.map_lock = false
	#SceneManager.change_scene("res://scenes/map.tscn")

func display_victory(gold_obtained: int = -1):
	popup = VictoryDefeatPopup.instantiate()
	get_tree().root.add_child(popup)
	if gold_obtained == -1:
		popup.show_victory_screen() #if no gold value specified, don't display "you got gold" text
	else:
		popup.show_victory_screen(gold_obtained)

func display_defeat():
	popup = VictoryDefeatPopup.instantiate()
	get_tree().root.add_child(popup)
	popup.show_defeat_screen()
