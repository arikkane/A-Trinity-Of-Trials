extends Node2D

#currently the sprites used for the enemies are smaller, so the sprite scale is increased. This as well as all
#child nodes will need to be adjusted once we have the final sprites

#Are we really loading the entire card deck into the contents of Enemy? Yes, yes we are.
var card_data = JsonLoader.load_cards()

var enemy_name = "Enemy"
var id #The enemy's LOCAL ID, not it's global one. for example, if it was the 2nd enemy in the battle it'd have id 2
var max_hp = 100
var hp = 70
var block = 0
var card_ids: Array = Array() #simply used to store the card ids until they can be converted into proper cards then put into enemy_deck
var enemy_deck: Array = []
var enemy_discard: Array = []
	

func _ready() -> void:
	#init_health_bar()
	print("Enemy has been spawned.")
	

#Initiate position of health bar
func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	$"EnemyDataUI/HealthBar".position.x = $"Sprite2D".position.x
	$"EnemyDataUI/HealthBar".position.y = $"Sprite2D".position.y
	update_health_bar()

#THIS NEEDS FIXING!
func init_enemy_sprite(enemysprite):
	#adjust X position based on enemy ID
	var x = 1100
	if id == 0:
		x += 200
	elif id == 1:
		x+= 400
	elif id == 2:
		x+= 600
	elif id == 3:
		x+= 800
	
	#base y = 568
	var sprite_height = $"Sprite2D".texture.get_height()
	var sprite_width = $"Sprite2D".texture.get_width()
	$"Sprite2D".texture = load(enemysprite)
	$"Sprite2D".position = Vector2(x, 568)
	init_health_bar()

#call this whenever health is changed
func update_health_bar():
	$"EnemyDataUI/HealthBar".value = hp

func take_damage(amount):
	var remaining_damage = amount - block
	
	block = max(0,block - amount)
	
	if remaining_damage > 0:
		hp -= remaining_damage
		
	update_health_bar()
	
	if hp <= 0:
		die()

#Grabs the card IDs assigned to the enemy and turns them into a proper "deck"
func parse_card_ids():
	for i in len(card_ids):
		print("Parsing card ID " + str(card_ids[i]) + " of enemy...")
		
		#NOTE: This is essentially a mini-version of the function found in deck.gd.
		#Should the deck.gd card creation function be made global to clear up space?
		
		var card_data_resource = load("res://code/card_data.gd")
	
		var card = card_data_resource.new()
		card.type = card_data["cards"][card_ids[i]].get("type", "Utility")
		card.damage = card_data["cards"][card_ids[i]].get("damage", 0)
		card.block = card_data["cards"][card_ids[i]].get("block", 0)
		card.heal = card_data["cards"][card_ids[i]].get("heal", 0)
		#card.card_name = card_name_str
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
	print("Enemy  gained ", amount, " block. Total block: ", block)

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)
	print("Enemy healed ", amount, " HP. Total HP: ", hp)
	update_health_bar()

#When this is called, the node will destroy itself and all of its component.
func die():
	print("Enemy " + enemy_name + "  defeated!")
	queue_free()
