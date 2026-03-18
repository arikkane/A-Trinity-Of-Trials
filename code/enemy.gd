extends Node2D

#currently the sprites used for the enemies are smaller, so the sprite scale is increased. This as well as all
#child nodes will need to be adjusted once we have the final sprites

var max_hp = 100
var hp = 70
var block = 0
func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	update_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"EnemyDataUI/HealthBar".value = hp

func take_damage(amount):
	var remaining_damage = amount - block
	
	block = max(0,block - amount)
	
	if remaining_damage > 0:
		hp -= remaining_damage
		
	update_health_bar()
	
	if hp <= 0:
		die()
		
func gain_block(amount):
	block += amount
func die():
	print("Enemy defeated!")
	queue_free()
