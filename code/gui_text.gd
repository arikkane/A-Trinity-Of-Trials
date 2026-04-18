extends CanvasLayer

@onready var dtext = $"TextContainer/Info"

func ready_():
	$"CardNotice".hide()
	$"PickEnemyNotice".hide()

func card_selected_notice(display):
	if display == true:
		$"PickEnemyNotice".show()
	elif display == false:
		$"PickEnemyNotice".hide()
	else:
		$"PickEnemyNotice".hide()

func show_card_tip():
	$"CardNotice".show()
	$"AnimationPlayer".play("CardSelectionNotice")

func hide_info_bar():
	$"TextContainer".hide()

func set_info(text: String) -> void:
	$"TextContainer".show()
	dtext.text = text

#timer: the amount to wait after the text is done displaying
func show_text(display_text, timer):
	dtext.text = display_text
	await get_tree().create_timer(timer).timeout #is this bad coding practice?
	return
