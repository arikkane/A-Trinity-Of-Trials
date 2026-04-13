extends Node

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

var map_generated: bool = false
var saved_map_paths: Array = []
var saved_room_types: Array = []
var map_selected_path: Array = []
var map_available_nodes: Array = []

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
	if DeckDisplayUI == null:
		DeckDisplayUI = load("res://scenes/deck_display.tscn").instantiate()
		Main.add_child(DeckDisplayUI)

	DeckDisplayUI.update_cards()
	DeckDisplayUI.hide()

	UIOverlay.update_health()
	UIOverlay.update_gold()
	UIOverlay.show_ui()
	Map = MapScene.instantiate()
	Main.add_child(Map)
	Map.show_map()

func encounter_complete():
	# Map scene will handle its own setup when reloaded
	pass
