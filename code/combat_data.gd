extends RoomData
class_name CombatData

@export var enemies: Array[String]
@export var max_gold: int = 12
@export var min_gold: int = 8

enum Enemy {
	GOBLIN,
	SKELETON
}

#---NOTICE---
# When adding new enemies, ensure all fields are valid or problems may occur!!
# Refer to cards.json when deciding what cards you would like to give to an enemy. 

const ENEMY_DETAILS : Dictionary = {
	Enemy.GOBLIN: {
		"name": "Goblin",
		"hp": 70,
		"maxHp": 100,
		"cards": [12, 12, 12, 13, 13, 13, 8, 8],
		"sprite": "res://assets/Monsters/goblin_1.png"
	}, 
	Enemy.SKELETON: {
		"name": "Skeleton",
		"hp": 70,
		"maxHp": 100,
		"cards": [7, 7, 7, 7],
		"sprite": "res://assets/Monsters/skeleton_1.png"
	}
}
