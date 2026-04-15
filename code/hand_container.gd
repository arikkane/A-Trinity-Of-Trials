extends Control

var card_array: Array[Control]
var side_margin

func _ready():
	side_margin = get_parent().card_width + get_parent().side_margin*2
	global_position.y = get_tree().root.get_visible_rect().size.y - (get_parent().card_height + get_parent().bottom_margin)

func set_transforms():
	side_margin = get_parent().card_width + get_parent().side_margin*2
	global_position = Vector2(side_margin, get_tree().root.get_visible_rect().size.y - (get_parent().card_height + get_parent().bottom_margin))
	size = Vector2(get_tree().root.get_visible_rect().size.x - side_margin*2, get_parent().card_height)
	$"HBoxContainer".alignment = PRESET_CENTER
	print("HBoxContainer size: " + str($"HBoxContainer".size))

func add_card(card:Control):
	card_array.append(card)
	$"HBoxContainer".add_child(card)
	card.visible = true
	if not BattleManager.enable_input.is_connected(card._on_input_enabled):
		BattleManager.enable_input.connect(card._on_input_enabled)
	if not BattleManager.disable_input.is_connected(card._on_input_disabled):
		BattleManager.disable_input.connect(card._on_input_disabled)
	if not BattleManager.enemy_turn_ended.is_connected(card._on_enemy_turn_ended):
		BattleManager.enemy_turn_ended.connect(card._on_enemy_turn_ended)
	if not BattleManager.player_turn_ended.is_connected(card._on_player_turn_ended):
		BattleManager.player_turn_ended.connect(card._on_player_turn_ended)
	update_card_positions()

func remove_card(card:Control):
	card_array.erase(card)
	$"HBoxContainer".remove_child(card)
	card.visible = false
	if BattleManager.enable_input.is_connected(card._on_input_enabled):
		BattleManager.enable_input.disconnect(card._on_input_enabled)
	if BattleManager.disable_input.is_connected(card._on_input_disabled):
		BattleManager.disable_input.disconnect(card._on_input_disabled)
	if BattleManager.enemy_turn_ended.is_connected(card._on_enemy_turn_ended):
		BattleManager.enemy_turn_ended.disconnect(card._on_enemy_turn_ended)
	if BattleManager.player_turn_ended.is_connected(card._on_player_turn_ended):
		BattleManager.player_turn_ended.disconnect(card._on_player_turn_ended)
	update_card_positions()

func update_card_positions():
	if not card_array.is_empty():
		var container_width = get_parent().card_width*card_array.size()
		size.x = container_width
		global_position.x = (get_tree().root.get_visible_rect().size.x - container_width)/2
		#var card_spacing = 0
		##increases the overlap by 16 pixels for every card over 6 in the players hand
		#if card_array.size() > 6:
			#card_spacing += (card_array.size()-6)*-16
		#else:
			#card_spacing = 0
		#var hand_width = (card_array.size() * get_parent().card_width) + ((card_array.size()-1) * card_spacing)
		##x coordinate of the far left side of the hand node
		#var start_x = (get_tree().root.get_visible_rect().size.x - hand_width)/2
		#for i in range(card_array.size()):
			#print("Card #" + str(i))
			#print("  texture size: " + str(card_array[i].get_node("TextureRect").size))
			#print("  texture position: " + str(card_array[i].get_node("TextureRect").global_position))
			#print("  card width: " + str(get_parent().card_width))
			#card_array[i].global_position.x = start_x + i * (get_parent().card_width+card_spacing)
			#card_array[i].global_position.y = get_parent().card_y
