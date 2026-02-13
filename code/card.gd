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
var debug_label: RichTextLabel

func _ready() -> void:
	init_debug_label()

func init_debug_label():
	debug_label.text = "Card ID: " + str(card_id) + "\nCard Type:"

func update_debug_label():
	
