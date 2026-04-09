extends Node

#current enemy global to be passed to combat.gd. This was the easiest way to do this, and I'm aware there are probably better ways to do so
var current_enemies: Array[EnemyData.Enemy] #Contains the pre-init structure for the enemies.

var isInBattle = false #make it so that the player can't select cards outside of battle
var enemy_list = [] #contains the actual current enemies in battle

#All of these relate to user choices. 
var selected_enemy = null
var selecting_target = false
var selected_card = null

#Initialize a battle
func start_battle(enemy: Array[EnemyData.Enemy]):
	current_enemies = enemy
	#print(EnemyData.ENEMY_DETAILS[enemy]["name"])
	print(enemy)
	#CombatData.ENEMY_DETAILS[enemy].name
	isInBattle = true
	SceneManager.change_scene("res://scenes/combat.tscn")

#reset selections
func reset_selections():
	selected_enemy = null
	selecting_target = false
	selected_card = null
