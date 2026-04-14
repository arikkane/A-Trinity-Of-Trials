extends Control

#should have attributes for damage, blocking, healing, etc.
#will also hold the logic for dragging and dropping

var combat
var card_data: CardData

#depreciating below as this data will be stored in card_data
#Damage, Utility, or Power
#var card_id = 0
#var type: String = ""
#var card_name: String = ""
#var damage = 0
#var block = 0
#var heal = 0
#var description = null
#var draw_amount: int = 0
#flag for if the card is in the players hand
var in_hand = false
var debug_label: RichTextLabel
#flag that prevents cards from being used, this flag is primarily used in the deck display ui
var deck_display_copy = false

var useable = true
signal card_selected(card)

#flag that checks to see if card is selected
var selected = false
var selectable = true

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(192, 288)  # give the card real size
	print(self.position.y)
	init_debug_label()

# Dragging
var dragging = false
var drag_offset = Vector2.ZERO

func play(target):
	if not combat:
		return

	# Always go through combat
	combat.play_card(self, target)

func _on_input_enabled():
	if (GameManager.PlayerHP >= GameManager.PlayerMaxHP) and card_data.type == "Utility" and card_data.block == 0: #if player is at max health, disallow healing items
		set_selectable(false)
	else:
		set_selectable(true)

func _on_input_disabled():
	reset_selection()
	set_selectable(false)

#Called from hand_container.gd
func _on_player_turn_ended():
	_on_input_disabled() #disable input after enemy turn ends

#Also called from hand_container.gd
func _on_enemy_turn_ended():
	_on_input_enabled() #enable input after enemy turn ends

#please always let this be true or false
func set_selectable(value):
	if value == true:
		selectable = true
		modulate = Color(1,1,1,1)
	elif value == false:
		selectable = false
		modulate = Color(0.5,0.5,0.5,1)
	else:
		selectable = true
		modulate = Color(1,1,1,1)

#resets a card to the non-selected state
func reset_selection():
	combat.gui_text.card_selected_notice(false)
	if selected == true:
		selected = false
	self.position.y = 0

#Function that handles selecting the card.
func select_card():
	if BattleManager.in_combat == true:
		if selectable == true:
			#If card is selected, deselect.
			if selected == true:
				AudioManager.play_sfx("cancel")
				reset_selection()
				combat.gui_text.card_selected_notice(false)
				BattleManager.reset_selections()
				return
			
			#If another card is selected, do nothing. Make sure the user deselects before picking another card.
			if selected == false && !BattleManager.selected_card == null:
				combat.show_card_tip()
				return
			
			#If neither of the above criteria is true, play the card.
			if card_data.type == "Damage":
				AudioManager.play_sfx("select")
				
				#If there's only one enemy left, just play the card without initiating the selection sequence.
				#if BattleManager.enemy_list.size() == 1:
				#	play(BattleManager.enemy_list[0])
				#	return
				
				combat.gui_text.card_selected_notice(true)
				BattleManager.selected_card = self
				BattleManager.selecting_target = true
				self.position.y = self.position.y - 70
				
				print("Selected card: " + str(self))
				selected = true
			elif card_data.type == "Utility": #if the card is utility, just play it
				AudioManager.play_sfx("select")
				play(combat.enemy)
		else:
			AudioManager.play_sfx("cancel")

func _gui_input(event):
	if useable and event is InputEventMouseButton and event.pressed:
		print("Clicked. Combat is:", combat)
		select_card()
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#if not deck_display_copy:
		#	print("Clicked. Combat is:", combat)
		#	play(combat.enemy)
		#elif deck_display_copy and GameManager.DeckDisplayUI.remove_selecting:
		#	GameManager.Deck.remove_card(card_data.uid)
		#	GameManager.DeckDisplayUI.card_removed()


#deprecated functionality, remove this before the final submission.
func check_drop_target():
	if combat and combat.enemy:
		var enemy_pos = combat.enemy.get_global_position()
		var enemy_size = Vector2(128, 128)
		var enemy_rect = Rect2(enemy_pos, enemy_size)
		if enemy_rect.has_point(get_global_mouse_position()):
			play(combat.enemy)




# debugging
func init_debug_label():
	debug_label = RichTextLabel.new()
	#makes the debug label object ignore the mouse input
	debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#enables font settings
	debug_label.bbcode_enabled = true
	add_child(debug_label)
	#sets the size of the label, needed for the label to be visible
	debug_label.custom_minimum_size = Vector2(108, 280)
	#sets the position to the label relative to the card
	debug_label.position = Vector2(self.position.x+10, self.position.y+10)

func update_debug_label():
	var label_text = "ID: " + str(card_data.id) + "\nName: " + str(card_data.name) + "\nType: " + str(card_data.type)
	if card_data.type == "Damage":
		label_text += "\nDamage: " + str(card_data.damage)
	elif card_data.type == "Utility":
		label_text += "\nBlock: " + str(card_data.block) + "\nHeal: " + str(card_data.heal)
	label_text += "\nDescription: " + str(card_data.description)
	debug_label.clear()
	#sets the font color
	debug_label.push_color(Color("Black"))
	#sets the font size
	debug_label.push_font_size(18)
	debug_label.add_text(label_text)
