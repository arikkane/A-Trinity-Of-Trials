extends Node2D

#currently the sprites used for the enemies are smaller, so the sprite scale is increased. This as well as all
#child nodes will need to be adjusted once we have the final sprites

var max_hp = 100
var hp = 50

func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	update_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"EnemyDataUI/HealthBar".value = hp
