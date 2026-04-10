extends RoomData
class_name EventData

enum EventType { TREASURE, HEAL, TRAP, CHOICE_CARD }

# Basic info

@export var type: int = EventType.TREASURE
@export var description: String

# Optional parameters
@export var choices: Array[String] = []   # for choice events
@export var reward: int = 0              # treasure / buffs
@export var damage: int = 0              # trap / ambush damage

# Optional scene for complex events
@export var event_scene: PackedScene
