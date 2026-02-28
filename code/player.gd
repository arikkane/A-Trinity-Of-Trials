extends Node2D

#likely how the player node will function is that it will be initialized in the initial game node and
#then get passed through a SceneLoader script that will handle transitions between rooms

#player starts with 0 block value
var block = 0
func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"CharacterDataUI/HealthBar".max_value = GameManager.PlayerMaxHP
	update_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"CharacterDataUI/HealthBar".value = GameManager.PlayerHP

func take_damage(amount):
	var remaining_damage = amount - block
	block = max(0, block - amount)
	
	if remaining_damage > 0:
		GameManager.PlayerHP -= remaining_damage
		
		update_health_bar()
		
	if GameManager.PlayerHP <= 0:
		die()

func gain_block(amount):
	block += amount
	print("Player gained ", amount, " block. Total block: ", block)

func heal(amount):
	GameManager.PlayerHP = min(GameManager.PlayerHP + amount, GameManager.PlayerMaxHP)
	update_health_bar()

func die():
	print("You have been defeated")
#need to add restart function
