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
	
	
	combat_start()
	start_player_turn()
	update_mana_label()
	update_block_label()
#moves cards from the deck to the draw pile and shuffles it
func combat_start():
	card_y = get_tree().root.get_visible_rect().size.y - card_height - bottom_margin
	init_pile_transforms()
	for i in range(GameManager.Deck.full_deck.size()):
		$"DrawPile".card_array.append(GameManager.Deck.full_deck[i])
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
#initalize enemy function
func enemy_turn():
	print("Enemy's turn")
	var damage = 20

	if player.block > 0:
		player.take_damage(damage - player.block)
	else:
		player.take_damage(damage)
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
	if card.type == "Damage":
		var damage = card.damage

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
	elif card.type == "Utility":
		if card.block > 0:
			player.gain_block(card.block)
			update_block_label()

		if card.heal > 0:
			player.heal(card.heal)

		# Draw cards if card has draw_amount
		if card.draw_amount > 0:
			# Cards drawn from this effect trigger Mage passive
			draw_cards(card.draw_amount, true)

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
