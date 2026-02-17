extends Node2D

#likely how the player node will function is that it will be initialized in the initial game node and
#then get passed through a SceneLoader script that will handle transitions between rooms

var max_hp = 100
var hp = 50
#amount of cards the player will draw per turn
var cards_per_turn = 6

func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"CharacterDataUI/HealthBar".max_value = max_hp
	update_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"CharacterDataUI/HealthBar".value = hp
