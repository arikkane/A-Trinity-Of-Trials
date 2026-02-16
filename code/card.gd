extends Control

#should have attributes for damage, blocking, healing, etc.
#will also hold the logic for dragging and dropping

var card_id = 0
var type = null
var damage = 0
var block = 0
var heal = 0
var description = null
var in_hand = false
var debug_label = null

func _ready() -> void:
	init_debug_label()

func init_debug_label():
	debug_label = RichTextLabel.new()
	#makes the debug label object ignore the mouse input
	debug_label.mouse_filter = true
	#enables font settings
	debug_label.bbcode_enabled = true
	add_child(debug_label)
	#sets the size of the label, needed for the label to be visible
	debug_label.custom_minimum_size = Vector2(108, 280)
	#sets the position to the label relative to the card
	debug_label.position = Vector2(self.position.x+10, self.position.y+10)

func update_debug_label():
	var label_text = "ID: " + str(card_id) + "\nType: " + str(type)
	if type == "Damage":
		label_text += "\nDamage: " + str(damage)
	elif type == "Utility":
		label_text += "\nBlock: " + str(block) + "\nHeal: " + str(heal)
	label_text += "\nDescription: " + str(description)
	debug_label.clear()
	#sets the font color
	debug_label.push_color(Color("Black"))
	#sets the font size
	debug_label.push_font_size(18)
	debug_label.add_text(label_text)
