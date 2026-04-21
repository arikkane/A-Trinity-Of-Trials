extends Node
class_name EnemyData

const ENEMY_DETAILS := {
	"goblin_1": {
		"name": "Goblin",
		"hp": 70,
		"maxHp": 70,
		"cards": [12, 12, 12, 12, 8, 8],
		"sprite": "res://assets/Monsters/goblin_1.png"
	},
	"goblin_2": {
		"name": "Goblin",
		"hp": 90,
		"maxHp": 90,
		"cards": [12, 12, 13, 13, 8, 8, 5],
		"sprite": "res://assets/Monsters/goblin_2.png"
	},
	"goblin_3": {
		"name": "Goblin Bomber",
		"hp": 50,
		"maxHp": 50,
		"cards": [14, 14, 8, 8, 8, 8, 8, 8],
		"sprite": "res://assets/Monsters/goblin_4.png"
	},
	"skeleton_1": {
		"name": "Skeleton",
		"hp": 70,
		"maxHp": 70,
		"cards": [12, 12, 12, 15],
		"sprite": "res://assets/Monsters/skeleton_1.png"
	},
	"skeleton_2": {
		"name": "Skeleton",
		"hp": 90,
		"maxHp": 90,
		"cards": [12, 12, 13, 13, 13, 16, 16,],
		"sprite": "res://assets/Monsters/skeleton_2.png"
	},
	"skeleton_3": {
		"name": "Skeleton",
		"hp": 110,
		"maxHp": 110,
		"cards": [13, 17, 17, 17, 17, 17, 17, 16, 16],
		"sprite": "res://assets/Monsters/skeleton_3.png"
	},
	"lich_boss": {
		"name": "Lich Boss",
		"hp": 250,
		"maxHp": 250,
		"cards": [],
		"sprite": "res://assets/Monsters/lich.png",
		"is_boss": true,
	}
}
