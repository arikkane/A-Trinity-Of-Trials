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
var Map: Node2D
var MapGridWidth = 8
var MapGridHeight = 6

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
	DeckDisplayUI = load("res://scenes/deck_display.tscn").instantiate()
	DeckDisplayUI.update_cards()
	DeckDisplayUI.hide()
	Main.add_child(DeckDisplayUI)
	Map = load("res://scenes/map.tscn").instantiate()
	Main.add_child(Map)
	UIOverlay.update_health()
	UIOverlay.update_gold()
	UIOverlay.show_ui()

func encounter_complete():
	Map.show_map()
	Map.map_lock = false
