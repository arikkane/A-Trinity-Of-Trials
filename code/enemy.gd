extends Node2D

var max_hp = 100
var hp = 50

func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	update_health_bar()

func update_health_bar():
	$"EnemyDataUI/HealthBar".value = hp
