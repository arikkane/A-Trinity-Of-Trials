extends Node

#This script is autoloaded via Project/Globals tab, and contains the player node as well as the functions needed to transition between
#different scenes.
var PlayerMaxHP = 0
var PlayerHP = 0
var CardsDrawnPerTurn = 0
var Deck: Control

func _ready() -> void:
	print("GameManager loaded")

func init_player_variables(maxhp,cdpt):
	print("In init_player_variables")
	PlayerMaxHP = maxhp
	PlayerHP = maxhp
	CardsDrawnPerTurn = cdpt
	Deck = load("res://scenes/deck.tscn").instantiate()
	add_child(Deck)
	Deck.init_cards()
