extends Resource
class_name CardData

#all types
@export var scene: PackedScene = load("res://scenes/card.tscn")
@export var uid: int
@export var id: int
@export var name: String
@export var type: String
@export var description: String
@export var count: int

#damage type
@export var damage: int

#utility type
@export var block: int
@export var heal: int
@export var draw: int
