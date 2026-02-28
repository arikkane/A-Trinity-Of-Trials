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

var player_turn = true
var max_mana = 5
var player_mana = 3

func _ready() -> void:
	player = $"Player"
	enemy = $"Enemy"
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

# Drawing cards:
#draws cards from the draw pile at the start of every turn
func draw_cards():
	for i in range(GameManager.CardsDrawnPerTurn):

		# If draw pile empty, reshuffle discard
		if $"DrawPile".card_array.size() == 0:
			reshuffle_discard_into_draw()

		if $"DrawPile".card_array.size() == 0:
			return

		var current_card = $"DrawPile".card_array.back()
		$"DrawPile".remove_card(current_card)
		$"HandContainer".add_card(current_card)

		current_card.combat = self
		current_card.update_debug_label()


func reshuffle_discard_into_draw():
	while $"DiscardPile".card_array.size() > 0:
		var card = $"DiscardPile".card_array.back()
		$"DiscardPile".remove_card(card)
		$"DrawPile".add_card(card)

	$"DrawPile".card_array.shuffle()

func move_to_discard(card):
	$"HandContainer".remove_card(card)
	$"DiscardPile".add_card(card)


func play_card(card, target):

	if not player_turn:
		return

	if player_mana <= 0:
		print("Not enough mana")
		return

	player_mana -= 1
	update_mana_label()
	# Apply effects
	if card.type == "Damage":
		target.take_damage(card.damage)

	elif card.type == "Utility":
		if card.block > 0:
			player.gain_block(card.block)
			update_block_label()

		if card.heal > 0:
			player.heal(card.heal)

	move_to_discard(card)

	check_victory()


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
