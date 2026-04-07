extends Node

#current enemy global to be passed to combat.gd. This was the easiest way to do this, and I'm aware there are probably better ways to do so
#Currently only holds one enemy. Will allow for up to 4 once basic combat is done
#var current_enemy: EnemyData.Enemy#
var current_enemies: Array[EnemyData.Enemy]

#Initialize a battle
func start_battle(enemy: Array[EnemyData.Enemy]):
	current_enemies = enemy
	#print(EnemyData.ENEMY_DETAILS[enemy]["name"])
	print(enemy)
	#CombatData.ENEMY_DETAILS[enemy].name
	SceneManager.change_scene("res://scenes/combat.tscn")
