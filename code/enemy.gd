extends Node2D

#currently the sprites used for the enemies are smaller, so the sprite scale is increased. This as well as all
#child nodes will need to be adjusted once we have the final sprites

var max_hp = 100
var hp = 70
var block = 0
var damage = 20
var double = false
var effects = {}
var actions: Array  = [doublepower,attack,apply_poison,apply_debuff,gain_block]

func _ready() -> void:
	init_health_bar()

func init_health_bar():
	$"EnemyDataUI/HealthBar".max_value = max_hp
	update_health_bar()

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
		
func gain_block(amount):
	block += amount
func die():
	print("Enemy defeated!")
	queue_free()
#doubles the users power for 1 turn and then attacks
func doublepower():
	double = true
	if(double):
		attack()
		damage = 2*damage
		double = false
	else:
		return
#enemy performs an attack with a random integer range from 0-20
func attack():
	damage = randi_range(0,20)

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
		damage = damage/2
		i["duration"] -= 1
		if i["duration"] <=0:
			effects.erase("debuff")
		
