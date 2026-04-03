extends Node

#combat node holds all the related nodes necessary for the combat encounter

#variables used to set the transform for all the cards/piles
var card_width = 192
var card_height = 288
var side_margin = 32
var bottom_margin = 32
var card_y = 0

#combatr state variables

var player
var enemy
var player_class = null
var player_turn = true
var max_mana = 5
var player_mana = 3

var max_hand = 6 #Temporary variable that contains how many cards the player can have in their hand!!

func _ready() -> void:
	player = $"Player"
	enemy = $"Enemy"
	
	player_class = GameManager.PlayerClass

	initialize_combat()


func initialize_combat() -> void:
	#Fetches enemy details from the current_enemy variable before starting combat
	#todo: run this multiple times depending on how many enemies are on the field
	var currentEnemy = BattleManager.current_enemy
	enemy.max_hp = CombatData.ENEMY_DETAILS[currentEnemy]["maxHp"]
	enemy.hp = CombatData.ENEMY_DETAILS[currentEnemy]["hp"]
	enemy.card_ids = CombatData.ENEMY_DETAILS[currentEnemy]["cards"]
	print(enemy.card_ids)
	enemy.parse_card_ids() #Convert the enemy's card IDs into actual cards. 
	
	combat_start()
	start_player_turn()
	update_mana_label()
	update_block_label()
	#moves cards from the deck to the draw pile and shuffles it
	print(enemy)

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
	$"DiscardPile".set_transforms()



# Turn System
func start_player_turn():
	player_turn = true
	player_mana = max_mana
	player.block = 0
	update_mana_label()
	draw_cards()
	update_block_label()
	print("player turn has started")
	
# method to end player and enemys turns
func end_player_turn():

	if not player_turn:
		return

	player_turn = false
	print("Player turn ended")

	enemy_turn()

#Enemy playing a card function
func enemy_play_card(enemy_card):
	if not enemy.enemy_deck.is_empty():
		#var enemy_card = enemy.enemy_deck.size
		
		# ----------------------
		# Apply card effects. For the time being, mana is irrelevant to enemies
		# ----------------------
		if enemy_card.type == "Damage":
			var damage = enemy_card.damage
			player.take_damage(damage - player.block)
		elif enemy_card.type == "Utility":
			if enemy_card.block > 0:
				enemy.gain_block(enemy_card.block)
				update_block_label()
			
			if enemy_card.heal > 0:
				enemy.heal(enemy_card.heal)
		
		enemy.enemy_deck.erase(enemy_card)
		enemy.enemy_discard.append(enemy_card)
		print("Played and moved " + enemy_card.name + " to enemy's discard pile")
		
	
#Function for handling an enemy's turn
func enemy_turn():
	print("Enemy's turn")
	
	#If the enemy deck is empty, shuffle it and put it back into the enemy's main deck, just like you would for the player
	if enemy.enemy_deck.is_empty():
		enemy.shuffle_deck()
	
	#For now, the enemy will pick a card randomly
	#Once the combat system is more complete, I will make it so that the enemy can make intelligent decisions
	var enemy_card = randi_range(1, enemy.enemy_deck.size()) - 1 #pick random card
	print(enemy.enemy_deck.size())
	enemy_play_card(enemy.enemy_deck[enemy_card])
	
	#With 25% probability, the enemy will play 2 cards in one turn.
	if randf() < 0.25 and !enemy.enemy_deck.is_empty():
		enemy_play_card(enemy.enemy_deck[randi_range(1, enemy.enemy_deck.size()) - 1])

	end_enemy_turn()



func end_enemy_turn():
	start_player_turn()

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

		target.take_damage(damage)

		# Alien passive: heal when dealing damage
		if GameManager.current_class == GameManager.PlayerClass.CREATURE:
			player.heal(damage)
			print("Alien heals for", damage)
			
		# mage passsive damage
		if GameManager.current_class == GameManager.PlayerClass.HEXTECHMAGE:
			damage = (damage + player.spell_power)
	elif card.card_data.type == "Utility":
		if card.card_data.block > 0:
			player.gain_block(card.card_data.block)
			update_block_label()

		if card.card_data.heal > 0:
			player.heal(card.card_data.heal)

		# Draw cards if card has draw_amount
		if card.card_data.draw > 0:
			# Cards drawn from this effect trigger Mage passive
			draw_cards(card.card_data.draw, true)

	# Move played card to discard
	move_to_discard(card)

	# Check victory conditions
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




func check_victory():

	if enemy.hp <= 0:
		print("Victory!")
		combat_end()

	if GameManager.PlayerHP <= 0:
		print("Defeat!")
		combat_end()

# updates mana in screen
func update_mana_label():
	$ManaLabel.text = "Mana " + str(player_mana)
func update_block_label():
	$BlockValue.text = "Block" + str(player.block)

#end turn

func _on_end_turn_button_pressed() -> void:
	end_player_turn()
