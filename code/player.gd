# Player2D.gd
extends Node2D

@onready var sprite = $"Sprite2D"

var spell_power: int = 0
var block: int = 0
var weaken_turns: int = 0
var draw_penalty_turns: int = 0

@onready var tween: Tween = null
var normal_color: Color = Color(1, 1, 1)
var glow_color: Color = Color(1.5, 1.5, 1.5, 1.0) * 1.5
var damaged_color: Color = Color(0.921, 0.0, 0.037, 1.0) * 1.5
var healing_color: Color = Color(0.0, 0.961, 0.451, 1.0) * 1.5
var blocking_color: Color = Color(0.0, 0.46, 0.775, 1.0) * 1.5
var dead: Color = Color(1.0, 1.0, 1.0, 0.0)



func _ready() -> void:
	await get_tree().process_frame
	set_player_sprite()
	init_health_bar()

func set_player_sprite() -> void:
	print("Current class: ", GameManager.current_class)

	match GameManager.current_class:
		GameManager.PlayerClass.GUNDAM:
			sprite.texture = preload("res://sprites/ArmorChar.png")
			sprite.scale = Vector2(0.75, 0.75)
		GameManager.PlayerClass.HEXTECHMAGE:
			sprite.texture = preload("res://sprites/magechar.png")
			sprite.scale = Vector2(2.5, 2.5)
		GameManager.PlayerClass.CREATURE:
			sprite.texture = preload("res://sprites/voidchar (2).png")
			sprite.scale = Vector2(2.0, 2.0)
		_:
			push_error("Unknown current class: " + str(GameManager.current_class))
	
	global_position = Vector2(200, 698-(sprite.texture.get_height() * sprite.scale.y))



func init_health_bar() -> void:
	$"CharacterDataUI/HealthBar".max_value = GameManager.PlayerMaxHP
	update_health_bar()

func update_health_bar() -> void:
	$"CharacterDataUI/HealthBar".value = GameManager.PlayerHP
	$"CharacterDataUI/HPLabel".text = str(GameManager.PlayerHP) + " / " + str(GameManager.PlayerMaxHP)


func take_damage(amount: int) -> void:
	var play_break_sound = false
		
	var remaining_damage = amount - block
	print("remaining damage:" + str(remaining_damage))
	
	#if user's block is broken, play the crumble sound
	if (remaining_damage > 0 and block > 0):
		play_break_sound = true

	block = max(0, block - amount)
	print("player block: " + str(block))
	get_parent().update_block_label()
	

	if remaining_damage > 0:
		GameManager.PlayerHP -= remaining_damage
		GameManager.UIOverlay.update_health()
		if play_break_sound == true:
			AudioManager.play_sfx("crumble")
		play_damage_animation()
		update_health_bar()
	else:
		play_block_animation()

	if GameManager.PlayerHP <= 0:
		die()

func apply_weaken(turns: int) -> void:
	weaken_turns += turns
	print("Player weakened for ", turns, " turns. Total: ", weaken_turns)

func apply_draw_penalty(turns: int) -> void:
	draw_penalty_turns += turns
	print("Player draw penalty for ", turns, " turns. Total: ", draw_penalty_turns)

func gain_block(amount: int) -> void:
	block += amount
	play_block_animation()
	print("Player gained ", amount, " block. Total block: ", block)

func heal(amount: int) -> void:
	GameManager.PlayerHP = min(GameManager.PlayerHP + amount, GameManager.PlayerMaxHP)
	play_healing_animation()
	update_health_bar()

func die() -> void:
	await play_death_animation()
	
	print("You have been defeated")
	# Add restart or game over logic here


#---ANIMATION HANDLING---

#Resetting sprite after tweening animation ends
func reset_color():
	if tween:
		tween.kill()
	sprite.modulate = normal_color

func play_death_animation():
	reset_color()
	sprite.modulate = normal_color
	AudioManager.play_sfx("death_scream")
	tween = create_tween()
	tween.tween_property(sprite, "modulate", dead, 0.8)

func play_damage_animation():
	reset_color()
	sprite.modulate = damaged_color
	#AudioManager.play_sfx("punch")
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.25)

func play_healing_animation():
	reset_color()
	AudioManager.play_sfx("heal")
	sprite.modulate = healing_color
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.5)

func play_block_animation():
	reset_color()
	AudioManager.play_sfx("scrape")
	sprite.modulate = blocking_color
	tween = create_tween()
	tween.tween_property(sprite, "modulate", normal_color, 0.3)
