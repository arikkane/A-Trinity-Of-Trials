extends Node2D

#currently the sprites used for the enemies are smaller, so the sprite scale is increased. This as well as all
#child nodes will need to be adjusted once we have the final sprites

#Are we really loading the entire card deck into the contents of Enemy? Yes, yes we are.
var card_data = JsonLoader.load_cards()

#the enemy sprite itself. Use this for animating the sprite, not for the sprite itself
@onready var sprite = $"Sprite2D"

#--ENEMY VARIABLES--
var enemy_name = "Enemy"
var id #The enemy's LOCAL ID, not it's global one. for example, if it was the 2nd enemy in the battle it'd have id 2
var max_hp = 100
var hp = 70
var block = 0

#==HEAD==
#var damage = 20
var double = false
var effects = {}
var actions: Array  = [doublepower,apply_poison,apply_debuff,gain_block]
#===

var card_ids: Array = Array() #simply used to store the card ids until they can be converted into proper cards then put into enemy_deck
var enemy_deck: Array = []
var enemy_discard: Array = []

# ---Boss Phase System---
signal boss_phase_changed(new_phase: int)

var is_boss: bool = false
var boss_phase: int = 1
var phase1_index: int = 0
var phase2_index: int = 0
var damage_bonus: int = 0

# Phase 1: Defensive cycle used on the first run (no saved deck data)
const PHASE1_FIRST_RUN: Array = [
	{"action": "gain_block", "amount": 12},
	{"action": "deal_damage", "amount": 18},
	{"action": "gain_block", "amount": 10},
	{"action": "heal", "amount": 15},
]

# Phase 1: Cycle used when a previous run deck snapshot exists
const PHASE1_WITH_SNAPSHOT: Array = [
	{"action": "gain_block", "amount": 12},
	{"action": "draw_penalty"},
	{"action": "deal_damage", "amount": 18},
	{"action": "gain_strength", "amount": 3},
]

# Phase 2: Aggressive targeted moves
const PHASE2_CYCLE: Array = [
	{"action": "deal_damage", "amount": 22},
	{"action": "targeted_debuff"},
	{"action": "heavy_damage", "amount": 30},
	{"action": "drain", "amount": 10},
]

func get_next_boss_move() -> Dictionary:
	if boss_phase == 1:
		var cycle = PHASE1_WITH_SNAPSHOT if SaveManager.has_previous_run() else PHASE1_FIRST_RUN
		var move = cycle[phase1_index % cycle.size()]
		phase1_index += 1
		return move
	else:
		var move = PHASE2_CYCLE[phase2_index % PHASE2_CYCLE.size()]
		phase2_index += 1
		return move

func peek_next_boss_move() -> String:
	var move: Dictionary
	if boss_phase == 1:
		var cycle = PHASE1_WITH_SNAPSHOT if SaveManager.has_previous_run() else PHASE1_FIRST_RUN
		move = cycle[phase1_index % cycle.size()]
	else:
		move = PHASE2_CYCLE[phase2_index % PHASE2_CYCLE.size()]

	match move["action"]:
		"deal_damage":   return "⚠ " + enemy_name + " will attack for " + str(move.get("amount", 0) + damage_bonus) + " damage!"
		"heavy_damage":  return "⚠ " + enemy_name + " is winding up a heavy strike for " + str(move.get("amount", 0) + damage_bonus) + " damage!"
		"drain":         return "⚠ " + enemy_name + " will drain " + str(move.get("amount", 0)) + " HP from you!"
		"gain_block":    return "🛡 " + enemy_name + " will defend next turn."
		"heal":          return "💀 " + enemy_name + " will heal next turn."
		"gain_strength": return "⚠ " + enemy_name + " is gathering strength!"
		"draw_penalty":  return "⚠ " + enemy_name + " will curse your hand next turn!"
		"targeted_debuff": return "⚠ " + enemy_name + " is preparing a debuff!"
	return ""

func check_phase_transition() -> void:
	if is_boss and boss_phase == 1 and hp <= max_hp / 2:
		boss_phase = 2
		emit_signal("boss_phase_changed", 2)
		print("Boss entered Phase 2!")

#Relating to sprite animation tweens
@onready var tween: Tween = null
var normal_color: Color = Color(1, 1, 1)
var glow_color: Color = Color(1.5, 1.5, 1.5, 1.0) * 1.5
var damaged_color: Color = Color(0.921, 0.0, 0.037, 1.0) * 1.5
var healing_color: Color = Color(0.0, 0.961, 0.451, 1.0) * 1.5
var blocking_color: Color = Color(0.0, 0.46, 0.775, 1.0) * 1.5
var dead: Color = Color(1.0, 1.0, 1.0, 0.0)
signal death_anim_done #Signals to combat.gd that the enemy death animation is done.
signal enemy_died(enemy)


func _ready() -> void:
	#init_health_bar()
	print("Enemy has been spawned.")
	

#Initiate position of health bar
func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	#$"EnemyDataUI/HealthBar".position.x = $"Sprite2D".position.x
	#$"EnemyDataUI/HealthBar".position.y = $"Sprite2D".position.y
	update_health_bar()

func init_enemy_sprite(enemysprite):
	#adjust X position based on enemy ID
	var x = 1000
	if id == 0:
		x += 225
	elif id == 1:
		x+= 450
	elif id == 2:
		x+= 675
	elif id == 3:
		x+= 900
	
	#base y = 568
	
	$"Sprite2D".texture = load(enemysprite)
	var sprite_height = $"Sprite2D".texture.get_height()
	var sprite_width = $"Sprite2D".texture.get_width()
	$"Sprite2D/Area2D/CollisionShape2D".shape.set_size(Vector2(sprite_width, sprite_height))
	$"Sprite2D/Area2D/CollisionShape2D".position = Vector2(sprite_width / 2.0, sprite_height / 2.0)
	global_position = Vector2(x, 698-sprite_height)
	init_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"EnemyDataUI/HealthBar".value = hp

func take_damage(amount):
	var remaining_damage = amount - block
	
	block = max(0,block - amount)
	
	if remaining_damage > 0:
		hp -= remaining_damage
	
	if hp > 0:
		play_damage_animation()
		if is_boss:
			check_phase_transition()
	update_health_bar()

	if hp <= 0:
		die()

#Grabs the card IDs assigned to the enemy and turns them into a proper "deck"
func parse_card_ids():
	for i in len(card_ids):
		print("Parsing card ID " + str(card_ids[i]) + " of enemy...")
		
		#NOTE: This is essentially a mini-version of the function found in deck.gd.
		#Should the deck.gd card creation function be made global to clear up space? [ANSWER: no, not enough time.]
		
		var card_data_resource = load("res://code/card_data.gd")
	
		var card = card_data_resource.new()
		card.type = card_data["cards"][card_ids[i]].get("type", "Utility")
		card.damage = card_data["cards"][card_ids[i]].get("damage", 0)
		card.block = card_data["cards"][card_ids[i]].get("block", 0)
		card.heal = card_data["cards"][card_ids[i]].get("heal", 0)
		card.name = card_data["cards"][card_ids[i]].get("name", "Unnamed Card")  # assign node name to avoid confusion
		
		enemy_deck.append(card) #add the newly-compiled card to the enemy deck


	print("placeholder")

#shuffles discard pile, and moves it back into the enemy deck
func shuffle_deck() -> void:
	enemy_discard.shuffle()
	enemy_deck.append_array(enemy_discard)
	enemy_discard.clear()


func gain_block(amount: int) -> void:
	block += amount
	play_block_animation()
	print("Enemy  gained ", amount, " block. Total block: ", block)

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)
	play_healing_animation()
	print("Enemy healed ", amount, " HP. Total HP: ", hp)
	update_health_bar()

#When this is called, the node will destroy itself and all of its component.
func die():
	get_parent().disable_input()
	await play_death_animation()
	death_anim_done.emit()
	print("Enemy " + enemy_name + "  defeated!")
	emit_signal("enemy_died", self)
	queue_free()

#===HEAD===

#doubles the users power for 1 turn and then attacks
func doublepower():
	double = true
	if(double):
		#attack()
		#damage = 2*damage
		double = false
	else:
		return
#enemy performs an attack with a random integer range from 0-20
#func attack():
#	damage = randi_range(0,20)

#adds "poison" to the dictionary of effects which can be used to tick hp down
#for a duration of turns in combat
func apply_poison():
	effects["poison"] = {"duration" = 3, "dpt" = 5}
	print ("Player was poisoned for 3 turns!")
	
	
#adds "debuff" to the dictionary of effects which will cause the player to deal
#less damage on their next turn
func apply_debuff():
	effects["debuff"] = {"duration":1}
	print("player will do less damage this round")

#execute_action is a function that puts every enemy action into an array and
#picks one at random to perform on a turn
func execute_action():
	var random: Callable = actions.pick_random()
	random.call()


#effects_status is ran for the player and checks if they have any status effects
# if they do it will process the effect and lower the duration by 1
func effects_status():
	if effects.has("poison"):
		var i = effects["poison"]
		hp -= i["dpt"]
		i["duration"] -= 1
		
		if i["duration"] <= 0:
			effects.erase("poison")
	if effects.has("debuff"):
		var i = effects["debuff"]
		#damage = damage/2
		i["duration"] -= 1
		if i["duration"] <=0:
			effects.erase("debuff")
		
#=======

#for if the player somehow presses end turn before the damn death animation is finished
func force_kill():
	queue_free()

#---ANIMATION HANDLING---

var _pulse_ghost: Sprite2D = null

func start_phase2_pulse() -> void:
	if _pulse_ghost != null:
		return

	_pulse_ghost = Sprite2D.new()
	_pulse_ghost.texture = sprite.texture
	_pulse_ghost.centered = sprite.centered
	_pulse_ghost.offset = sprite.offset
	_pulse_ghost.position = Vector2.ZERO
	_pulse_ghost.scale = Vector2.ONE
	_pulse_ghost.modulate = Color(1.0, 0.0, 0.0, 0.0)
	_pulse_ghost.z_index = 1
	sprite.add_child(_pulse_ghost)

	_run_pulse_cycle()

func _run_pulse_cycle() -> void:
	if _pulse_ghost == null:
		return
	_pulse_ghost.scale = Vector2.ONE
	_pulse_ghost.modulate = Color(1.0, 0.0, 0.0, 0.5)
	var t = create_tween()
	t.parallel().tween_property(_pulse_ghost, "scale", Vector2.ONE * 1.12, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_pulse_ghost, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.finished.connect(_run_pulse_cycle)

#Resetting sprite after tweening animation ends
func reset_color():
	if tween:
		tween.kill()
	sprite.modulate = normal_color

func play_attacking_animation():
	if tween:
		tween.kill()
	AudioManager.play_sfx("notice")
	sprite.modulate = glow_color
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.1)

func play_death_animation():
	reset_color()
	sprite.modulate = normal_color
	tween = create_tween()
	tween.tween_property(sprite, "modulate", dead, 0.8)
	await tween.finished
	tween.kill()
	death_anim_done.emit()
	return

func play_damage_animation():
	reset_color()
	sprite.modulate = damaged_color
	AudioManager.play_sfx("swordblow")
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.25)

func play_healing_animation():
	reset_color()
	sprite.modulate = healing_color
	AudioManager.play_sfx("heal")
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.5)

func play_block_animation():
	reset_color()
	sprite.modulate = blocking_color
	AudioManager.play_sfx("scrape")
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.3)

#---INPUT HANDLING--

#Selecting an enemy to attack by clicking on it.
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#If the battle manager has selected a card and is looking for a target, play the selected card on this enemy.
			if BattleManager.selecting_target == true:
				reset_color()
				BattleManager.selected_enemy = self
				AudioManager.play_sfx("select2")
				get_parent().play_card(BattleManager.selected_card, self)
				print("enemy clicked")

#Causes an enemy to glow when the player hovers over a target.
func _on_area_2d_mouse_entered() -> void:
	if BattleManager.selecting_target == true and hp != 0:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(sprite, "modulate", glow_color, 0.2)

#And then causes it to stop glowing after the mouse is no longer hovering over it
func _on_area_2d_mouse_exited() -> void:
	if BattleManager.selecting_target == true and hp != 0:
		if tween:
			tween.kill()
		reset_color()
