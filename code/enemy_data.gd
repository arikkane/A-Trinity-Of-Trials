extends Node
class_name EnemyData

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
		"hp": 5,
		"maxHp": 100,
		"cards": [12, 12, 12, 13, 13, 13, 8, 8],
		"sprite": "res://assets/Monsters/goblin_1.png"
	}, 
	Enemy.SKELETON: {
		"name": "Skeleton",
		"hp": 5,
		"maxHp": 100,
		"cards": [7, 7, 7, 7],
		"sprite": "res://assets/Monsters/skeleton_1.png"
	}
}
