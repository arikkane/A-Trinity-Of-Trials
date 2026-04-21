#The victory/defeat screen. 

extends CanvasLayer

var victory_img = preload("res://sprites/victory.png")
var defeat_img = preload("res://sprites/defeat.png")

var img
var results_container
var halfshowncolor: Color = Color(1.0, 1.0, 1.0, 0.447)
@onready var tween: Tween = null
#var fullcolor: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	print("Victory/defeat screen loaded")
	#hide()

#this is SO JANKY
func show_victory_screen(gold_obtained: int = 0):
	show()
	img = $"Control/TextureRect"
	img.texture = victory_img
	img.modulate = halfshowncolor
	img.scale = Vector2(0.5, 0.5)
	img.z_index = 3
	if gold_obtained > 0:
		$"Control/PanelContainer/MarginContainer/Label".text = "You earned [color=gold]" + str(gold_obtained) + "[/color] gold!"
	else:
		$"Control/PanelContainer/MarginContainer/Label".text = "Great job!"
	
	results_container = $"Control/PanelContainer"
	results_container.show()
	results_container.position.y = 1000
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(img, "modulate:a", 1.0, 2)
	tween.tween_property(img, "scale", Vector2(1, 1), 1.0)
	
	#make it so that this waits until the above is done before running this
	tween.set_parallel(false)
	
	var target_pos = img.position + Vector2(0, -240) # move up 120 pixels
	tween.tween_property(img, "position", target_pos, 0.4)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.set_parallel(true)
	tween.tween_property(results_container, "position", Vector2(640, 325), 0.4)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

func show_defeat_screen():
	show()
	$"Control/PanelContainer".hide()
	img = $"Control/TextureRect"
	img.texture = defeat_img
	img.modulate = halfshowncolor
	img.scale = Vector2(0.5, 0.5)
	img.z_index = 3
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(img, "modulate:a", 1.0, 3)
	tween.tween_property(img, "scale", Vector2(1, 1), 2.0)
	$"Control/AcceptDeath".show()


func _on_proceed_pressed() -> void:
	$"Control/PanelContainer".hide()
	hide()
	if tween:
		tween.kill()
	BattleManager.combat_finished(true)
	queue_free() #kill self. should this be here?

#accept you died
func _on_accept_death_pressed() -> void:
	if tween:
		tween.kill()
	BattleManager.combat_finished(false)
	queue_free() #kill self. should this be here?
