
extends Node

# ----------------------------
# Player variables
# ----------------------------
var PlayerMaxHP: int
var PlayerHP: int
var CardsDrawnPerTurn: int
var Deck: Control = null




enum PlayerClass {
	GUNDAM,
	HEXTECHMAGE,
	CREATURE
}

var current_class: PlayerClass = PlayerClass.GUNDAM

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
