extends Node

#combat node holds all the related nodes necessary for the combat encounter

@onready var gui_text = $"GUIText"
signal player_turn_ended

#variables used to set the transform for all the cards/piles
var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

#combatr state variables

var player
var enemy #No idea what this even does, but when I removed it, card.gd started throwing errors.

var turn_order = [] #contains the turn order
var player_class = null
var player_turn = true
var max_mana = 5
var player_mana = 3

var max_hand = 6 #Temporary variable that contains how many cards the player can have in their hand!!

func _ready() -> void:
	player = $"Player"
	
	player_class = GameManager.PlayerClass

	initialize_combat()


func initialize_combat() -> void:
	#Fetches enemy details from the current_enemy variable before starting combat
	turn_order.append(player) #but first add the player to the turn order
	
	var enemy_scene = preload("res://scenes/Enemy.tscn")
	var currentEnemy = BattleManager.current_enemies
	
	#Grabs a list of all the enemies that have been passed to combat.gd, and create them.
	for i in range(currentEnemy.size()):
		#Spawn a new enemy
		var enemy_child = enemy_scene.instantiate()
		
		#Now initiate all the enemy's stats
		enemy_child.enemy_name = EnemyData.ENEMY_DETAILS[currentEnemy[i]]["name"]
		enemy_child.max_hp = EnemyData.ENEMY_DETAILS[currentEnemy[i]]["maxHp"]
		enemy_child.hp = EnemyData.ENEMY_DETAILS[currentEnemy[i]]["hp"]
		enemy_child.card_ids = EnemyData.ENEMY_DETAILS[currentEnemy[i]]["cards"]
		enemy_child.id = i
		enemy_child.parse_card_ids() #Convert the enemy's card IDs into actual cards.
		enemy_child.init_enemy_sprite(EnemyData.ENEMY_DETAILS[currentEnemy[i]]["sprite"])
		enemy_child.enemy_died.connect(_on_enemy_death)
		print("Enemy spawned: " + enemy_child.name + ", HP: " + str(enemy_child.hp) + ", Cards: " + str(enemy_child.card_ids))
		add_child(enemy_child)
		BattleManager.enemy_list.append(enemy_child)
		turn_order.append(enemy_child)

	print("ENEMYLIST:")
	print(BattleManager.enemy_list)
	#Initiate everything
	combat_start()
	start_player_turn()
	update_mana_label()
	update_block_label()
	#moves cards from the deck to the draw pile and shuffles it

func combat_start():
	card_y = get_tree().root.get_visible_rect().size.y - card_height - bottom_margin
	init_pile_transforms()
	for i in range(GameManager.Deck.full_deck.size()):
		$"DrawPile".card_array.append(GameManager.Deck.full_deck[i].scene.instantiate())
		$"DrawPile".card_array.back().card_data = GameManager.Deck.full_deck[i].duplicate()
	$"DrawPile".card_array.shuffle()
	$"DrawPile".display_cards()


func combat_end():
	for i in range($"DrawPile".card_array.size()):
		$"DrawPile".remove_card($"DrawPile".card_array.back())
	for i in range($"DiscardPile".card_array.size()):
		$"DiscardPile".remove_card($"DiscardPile".card_array.back())
	for i in range($"HandContainer".card_array.size()):
		$"HandContainer".remove_card($"HandContainer".card_array.back())

#sets the position and size of the draw and discard pile
func init_pile_transforms():
	$"DrawPile".set_transforms()
	$"HandContainer".set_transforms()
	$"DiscardPile".set_transforms()



# Turn System
func start_player_turn():
	player_turn = true
	player_mana = max_mana
	player.block = 0
	$"EndTurnButton".show()
	update_mana_label()
	draw_cards()
	update_block_label()
	print("player turn has started")
	

#End the player turn
func end_player_turn():

	if not player_turn:
		return

	#emit the signal to end the player's turn, and also reset selections
	BattleManager.player_turn_ended.emit()
	BattleManager.reset_selections()
	
	player_turn = false
	print("Player turn ended")
	
	turn_logic()

#-------TURN LOGIC, THIS IS RESPONSIBLE FOR HANDLING TURNS.---------
func turn_logic():
	#The turn order uses a first-out-first-in queue structure
	turn_order.push_back(turn_order.pop_front())
	if !is_instance_valid(turn_order[0]): #This should NEVER be invalid thanks to check_enemies(), but it's here just to be safe.
		turn_order.pop_front()
		turn_logic()
	
	if turn_order[0].has_method("parse_card_ids"): #Making sure it's actually an enemy, since only enemies have this function.
		print(turn_order)
		enemy_turn(turn_order[0])
	else: #otherwise, assume it's the player's turn
		BattleManager.enemy_turn_ended.emit()
		start_player_turn()

#Enemy playing a card function
func enemy_play_card(enemy_user, enemy_card):
	#enemy_user: Passed from enemy_turn, this represents the enemy using the card. THIS SHOULD ALWAYS BE AN INSTANCE OF THE "Enemy" NODE
	#enemy_card: The card the enemy is playing; this is NOT the same data type as a player's card and is handled differently. Look into enemy.gd to see how it works 
	
	if not enemy_user.enemy_deck.is_empty():
		
		# ----------------------
		# Apply card effects. For the time being, mana is irrelevant to enemies
		# ----------------------
		if enemy_card.type == "Damage":
			var damage = enemy_card.damage
			enemy_user.play_attacking_animation()
			await show_text("" + enemy_user.enemy_name + " uses " + enemy_card.name + "!", 1)
			player.take_damage(damage)
			if player.block > 0:
				await show_text("Player's block negated all damage!\nPlayer took no damage!", 1)
			else:
				await show_text("Player takes " + str(damage) + " damage!", 1)
			
		elif enemy_card.type == "Utility":
			if enemy_card.block > 0:
				enemy_user.gain_block(enemy_card.block)
				await show_text("" + enemy_user.enemy_name + " gains " + str(enemy_card.block) + " block!", 1)
			
			if enemy_card.heal > 0:
				enemy_user.heal(enemy_card.heal)
				await show_text("" + enemy_user.enemy_name + " heals for " + str(enemy_card.heal) + " HP!", 1)
		
		enemy_user.enemy_deck.erase(enemy_card)
		enemy_user.enemy_discard.append(enemy_card)
		print("Played and moved " + enemy_card.name + " to enemy's discard pile")
		return
		
	
#Function for handling an enemy's turn
func enemy_turn(enemy_user):
	#enemy_user: represents which enemy is taking the turn. THIS SHOULD ALWAYS BE AN INSTANCE OF THE "Enemy" NODE 
	
	
	print("Enemy Turn: " + str(enemy_user))
	print(turn_order)
	
	#If the enemy deck is empty, shuffle it and put it back into the enemy's main deck, just like you would for the player
	if enemy_user.enemy_deck.is_empty():
		enemy_user.shuffle_deck()
	
	#For now, the enemy will pick a card randomly
	#Once the combat system is more complete, I will make it so that the enemy can make intelligent decisions
	var enemy_card = randi_range(1, enemy_user.enemy_deck.size()) - 1 #pick random card
	print(enemy_user.enemy_deck.size())
	
	await enemy_play_card(enemy_user, enemy_user.enemy_deck[enemy_card])
	
	#With 25% probability, the enemy will play 2 cards in one turn.
	if randf() < 0.25 and !enemy_user.enemy_deck.is_empty():
		await enemy_play_card(enemy_user, enemy_user.enemy_deck[randi_range(1, enemy_user.enemy_deck.size()) - 1])
	
	end_enemy_turn()


#Once the enemy's turn is over, go back to the turn logic.
func end_enemy_turn():
	turn_logic()

# Drawing cards and class passives:
#draws cards from the draw pile at the start of every turn
# ----------------------------
# Draw cards function
# ----------------------------
func draw_cards(count = null, from_effect = false):
	if count == null:
		count = GameManager.CardsDrawnPerTurn

	for i in range(count):
		# Reshuffle if draw pile empty
		if $"DrawPile".card_array.size() == 0:
			reshuffle_discard_into_draw()
		if $"DrawPile".card_array.size() == 0:
			return

		var current_card = $"DrawPile".card_array.back()

		if $"HandContainer".card_array.size() < max_hand:
			$"DrawPile".remove_card(current_card)
			$"HandContainer".add_card(current_card)
			current_card.combat = self
			current_card.update_debug_label()
			if GameManager.PlayerHP >= GameManager.PlayerMaxHP and current_card.card_data.type == "Utility" and current_card.card_data.block == 0:
				current_card.set_selectable(false)

			# ----------------------
			# Mage passive: buffs on drawn cards from effects
			# ----------------------
			if from_effect and GameManager.current_class == GameManager.PlayerClass.HEXTECHMAGE:
				player.spell_power += 1
				print("Mage gains +1 spell power! Current:", player.spell_power)


# ----------------------------
# Play card function
# ----------------------------
func play_card(card, target):
	gui_text.card_selected_notice(false)
	if not player_turn:
		return

	if player_mana <= 0:
		print("Not enough mana")
		return

	player_mana -= 1
	update_mana_label()

	# ----------------------
	# Apply card effects
	# ----------------------
	if card.card_data.type == "Damage":
		var damage = card.card_data.damage

		# Mecha assive: bonus damage based on block
		if GameManager.current_class == GameManager.PlayerClass.GUNDAM:
			damage += int(player.block * 0.5)  # 50% of current block as bonus damage
		
		#if (target.hp - min(0,(damage - target.block))) <= 0:
		if (target.hp - damage) < 0:
			show_text("" + target.enemy_name + " takes " + str(damage) + " damage!\n" + target.enemy_name + " was defeated!", 1)
		else:
			show_text("" + target.enemy_name + " takes " + str(damage) + " damage!", 1)
		BattleManager.reset_selections()
		target.take_damage(damage)
		
		#if target.hp < 0 and is_instance_valid(target):
		#	disable_input()
		#	await target.death_anim_done
		#	enable_input()
		
		# Alien passive: heal when dealing damage
		if GameManager.current_class == GameManager.PlayerClass.CREATURE:
			show_text("Player heals " + str(damage) + " HP!", 1)
			player.heal(damage)
			
		# mage passsive damage
		if GameManager.current_class == GameManager.PlayerClass.HEXTECHMAGE:
			damage = (damage + player.spell_power)
	elif card.card_data.type == "Utility":
		if card.card_data.block > 0:
			show_text("Player gains " + str(card.card_data.block) + " block!", 1)
			player.gain_block(card.card_data.block)
			update_block_label()

		if card.card_data.heal > 0:
			show_text("Player heals " + str(card.card_data.heal) + " HP!", 1)
			player.heal(card.card_data.heal)

		# Draw cards if card has draw_amount
		if card.card_data.draw > 0:
			# Cards drawn from this effect trigger Mage passive
			draw_cards(card.card_data.draw, true)

	# Move played card to discard
	move_to_discard(card)

	# Check victory conditions
	check_enemies()
	check_victory()

func reshuffle_discard_into_draw():
	while $"DiscardPile".card_array.size() > 0:
		var card = $"DiscardPile".card_array.back()
		$"DiscardPile".remove_card(card)
		$"DrawPile".add_card(card)

	$"DrawPile".card_array.shuffle()

func move_to_discard(card):
	$"HandContainer".remove_card(card)
	$"DiscardPile".add_card(card)


#Purge killed enemies from the queues.
func check_enemies():
	for i in range(BattleManager.enemy_list.size() - 1, -1, -1): #iterate BACKWARD or else THERE WILL BE PROBLEMS!
		if !is_instance_valid(BattleManager.enemy_list[i]):
			BattleManager.enemy_list.remove_at(i)
	
	#Do the same for the turn order
	for i in range(turn_order.size() - 1, -1, -1):
		if !is_instance_valid(turn_order[i]):
			turn_order.remove_at(i)

#called when an enemy dies
func _on_enemy_death(enemy):
	BattleManager.enemy_list.erase(enemy)
	turn_order.erase(enemy)
	#enable_input()
	#check_victory()
	
	#just in case the enemy entity somehow still exists
	if enemy:
		enemy.queue_free()

func check_victory():
	if BattleManager.enemy_list.is_empty():
		show_text("Winner!", 1)
		print("Victory!")
		combat_end()
		BattleManager.combat_finished(true)

	elif GameManager.PlayerHP <= 0:
		print("Defeat!")
		combat_end()
		BattleManager.combat_finished(false)
		
		

# updates mana in screen
func update_mana_label():
	$ManaLabel.text = "Mana " + str(player_mana)
func update_block_label():
	$BlockValue.text = "Block" + str(player.block)

#Display text on screen to the user
func show_text(text, timer):
	await gui_text.show_text(text, timer)
	return

#show the "you must deselect a card or attack an enemy!" tip
func show_card_tip():
	AudioManager.play_sfx("buzzer")
	gui_text.show_card_tip()

func disable_input():
	$"EndTurnButton".hide()
	BattleManager.disable_input.emit()

func enable_input():
	BattleManager.enable_input.emit()
	$"EndTurnButton".show()

#end turn
func _on_end_turn_button_pressed() -> void:
	$"EndTurnButton".hide()
	#for i in range(BattleManager.enemy_list.size() - 1, -1, -1): #iterate BACKWARD or else THERE WILL BE PROBLEMS!
	#	if (BattleManager.enemy_list[i].hp <= 0):
	#		BattleManager.enemy_list[i].force_kill()
	end_player_turn()
	
func _on_win_test_button_pressed() -> void:
	print("DEBUG: Forced victory")
	combat_end()
	BattleManager.combat_finished(true)


func _on_win_button_down() -> void:
	print("DEBUG: Forced victory")
	combat_end()
	BattleManager.combat_finished(true)
