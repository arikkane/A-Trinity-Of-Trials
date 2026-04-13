# BattleManager.gd
extends Node

# -----------------------------
# Public State
# -----------------------------
var current_enemies: Array = []
var current_room_data = null
var in_combat: bool = false

var enemy_list: Array = [] #contains the actual current enemies in battle. Replace this with current_room_data somehow?

#old code from before the signal system was in place. replace these with signals?
#NOTE: DONT REMOVE THIS UNLESS A REPLACEMENT IS IMPLEMENTED!
var selected_enemy = null
var selecting_target = false
var selected_card = null

# -----------------------------
# Signals
# -----------------------------
signal combat_started(room_data)
signal combat_ended(victory: bool)

signal player_turn_ended
signal enemy_turn_ended

# -----------------------------
# Called on startup
# -----------------------------
func _ready() -> void:
	if not EventBus.is_connected("combat_started", Callable(self, "_on_combat_node_selected")):
		EventBus.connect("combat_started", Callable(self, "_on_combat_node_selected"))

# -----------------------------
# Map -> Combat
# -----------------------------
func _on_combat_node_selected(room_data) -> void:
	if in_combat:
		print("⚠️ Already in combat. Ignoring node selection.")
		return

	if room_data == null:
		push_error("BattleManager: room_data is null.")
		return

	if not ("enemies" in room_data) and not room_data.get("enemies", null):
		# fallback for Resource-style objects with a direct property
		if room_data.enemies == null:
			push_error("BattleManager: room_data has no enemies array.")
			return

	var enemies = room_data.enemies
	if enemies == null or enemies.is_empty():
		push_error("BattleManager: selected combat room has no enemies.")
		return

	current_room_data = room_data
	current_enemies = enemies.duplicate()

	start_combat(enemies)

#NOTE: If called from outside of the map, make sure you assign an array of enemies to the enemy_data value. (ex. ["skeleton_1", "skeleton_2"])
func start_combat(enemy_data):
	in_combat = true
	print("BattleManager: starting combat with enemies: ", current_enemies)
	
	print(enemy_data)
	emit_signal("combat_started", enemy_data)
	SceneManager.change_scene("res://scenes/combat.tscn")

# -----------------------------
# Called by Combat.gd when fight ends
# -----------------------------
func combat_finished(victory: bool) -> void:
	if not in_combat:
		print("BattleManager: combat_finished called while not in combat.")
		return

	print("BattleManager: combat ended. Victory = ", victory)

	in_combat = false
	emit_signal("combat_ended", victory)

	if victory:
		# Do not fully wipe the encounter until after the map has a chance
		# to read any saved progress you may be tracking elsewhere.
		current_enemies.clear()
		current_room_data = null
		SceneManager.change_scene("res://scenes/map.tscn")
	else:
		reset_encounter()
		SceneManager.change_scene("res://scenes/ClassSelection.tscn")

# -----------------------------
# Utility: reset current encounter
# -----------------------------
func reset_encounter() -> void:
	current_enemies.clear()
	current_room_data = null
	in_combat = false

#reset selections
func reset_selections():
	selected_enemy = null
	selecting_target = false
	selected_card = null
