extends Control

var card_array: Array[Control]
var card_overlap = 0
func _ready() -> void:
	global_position = Vector2(960,760)

func add_card(card:Control):
	card_array.append(card)
	add_child(card)
	update_card_positions()

func remove_card(card:Control):
	card_array.erase(card)
	remove_child(card)
	update_card_positions()

func update_card_positions():
	var odd_offset = 0
	if card_array.size() > 8:
		card_overlap = 64
	else:
		card_overlap = 0
	if card_array.size()%2 == 0:
		odd_offset = 0
	else:
		odd_offset = 0.5
	if not card_array.is_empty():
		for i in range(card_array.size()):
			print("Card #" + str(i) + ": " + str(card_array[i].card_id))
			card_array[i].position = Vector2((i-(card_array.size()/2)-odd_offset)*(192-card_overlap),0)
