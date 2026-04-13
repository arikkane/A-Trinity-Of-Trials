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
var useable = true
signal card_selected(card)

#flag that checks to see if card is selected
var selected = false
var selectable = true

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(150, 220)  # give the card real size
	init_debug_label()

# Dragging
var dragging = false
var drag_offset = Vector2.ZERO

func play(target):
	if not combat:
		return

	# Always go through combat
	combat.play_card(self, target)

#Called from hand_container.gd
func _on_player_turn_ended():
	set_selectable(false)

#Also called from hand_container.gd
func _on_enemy_turn_ended():
	set_selectable(true)

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

#Function that handles selecting the card.
func select_card():
	if BattleManager.in_combat == true:
		if selectable == true:
			#If card is selected, deselect.
			if selected == true:
				AudioManager.play_sfx(preload("res://assets/Sounds/select3.wav"))
				selected = false
				BattleManager.reset_selections()
				self.position.y = self.position.y + 70
				return
			
			#If another card is selected, do nothing. Make sure the user deselects before picking another card.
			if selected == false && !BattleManager.selected_card == null:
				combat.show_card_tip()
				return
			
			#If neither of the above criteria is true, play the card.
			if card_data.type == "Damage":
				AudioManager.play_sfx(preload("res://assets/Sounds/select1.wav"))
				
				#If there's only one enemy left, just play the card without initiating the selection sequence.
				if BattleManager.enemy_list.size() == 1:
					play(BattleManager.enemy_list[0])
					return
					
				BattleManager.selected_card = self
				BattleManager.selecting_target = true
				self.position.y = self.position.y - 70
				
				print("Selected card: " + str(self))
				selected = true
			elif card_data.type == "Utility": #if the card is utility, just play it
				AudioManager.play_sfx(preload("res://assets/Sounds/select1.wav"))
				play(combat.enemy)
		else:
			AudioManager.play_sfx(preload("res://assets/Sounds/buzzer1.wav"))

#Function that handles selecting cards.
#func select_card():
#	if BattleManager.in_combat == true:
#		#If card is selected, deselect.
#		if selected == true:
#			AudioManager.play_sfx(preload("res://assets/Sounds/select3.wav"))
#			selected = false
#			BattleManager.reset_selections()
#			self.position.y = self.position.y + 70
#			return
#		
#		#If another card is selected, do nothing. Make sure the user deselects before picking another card.
#		if selected == false && !BattleManager.selected_card == null:
#			combat.show_card_tip()
#			return
#		
#		#If neither of the above criteria is true, play the card.
#		if card_data.type == "Damage":
#			AudioManager.play_sfx(preload("res://assets/Sounds/select1.wav"))
#			
#			#If there's only one enemy left, just play the card without initiating the selection sequence.
#			if BattleManager.enemy_list.size() == 1:
#				play(BattleManager.enemy_list[0])
#				return
#				
#			BattleManager.selected_card = self
#			BattleManager.selecting_target = true
#			self.position.y = self.position.y - 70
#			
#			print("Selected card: " + str(self))
#			selected = true
#		elif card_data.type == "Utility": #if the card is utility, just play it
#			AudioManager.play_sfx(preload("res://assets/Sounds/select1.wav"))
#			play(combat.enemy)

func _gui_input(event):
	if useable and event is InputEventMouseButton and event.pressed:
		print("Clicked. Combat is:", combat)
		select_card()

# CHECK IF DROPPED ON TARGET currenly debugging

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
