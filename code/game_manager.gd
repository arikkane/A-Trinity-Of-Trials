
extends Node

#This script is autoloaded via Project/Globals tab, and contains the player variables and deck node
var PlayerMaxHP = 0
var PlayerHP = 0
var PlayerGold = 50
var CardsDrawnPerTurn = 0
var PlayerPosition = 0

var UIOverlay: CanvasLayer

var Deck: Control
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

func init_player_variables(maxhp,cdpt):
	print("In init_player_variables")

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
	Map = load("res://scenes/map.tscn").instantiate()
	UIOverlay.update_health()
	UIOverlay.update_gold()
	

func encounter_complete():
	Map.show_map()
	Map.map_lock = false
