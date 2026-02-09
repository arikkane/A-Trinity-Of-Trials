extends Node2D

var character_class = null
var max_hp = 100
var hp = 50

func _ready() -> void:
	init_health_bar()

#character class initialization, should be called when run starts

func init_health_bar():
	$"CharacterDataUI/HealthBar".max_value = max_hp
	update_health_bar()

func update_health_bar():
	$"CharacterDataUI/HealthBar".value = hp
