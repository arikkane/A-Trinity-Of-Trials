extends CanvasLayer

func ready_():
	$"CardNotice".hide()

func show_card_tip():
	$"CardNotice".show()
	$"AnimationPlayer".play("CardSelectionNotice")
