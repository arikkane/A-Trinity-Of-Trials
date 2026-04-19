extends CanvasLayer

#GUIText handles the card notices and the text container.

@onready var dtext = $"TextContainer/Info"

func ready_():
	hide_all_visible_notices()

#does exactly what the function name says it'll do.
func hide_all_visible_notices():
	$"CardNotice".hide()
	$"PickEnemyNotice".hide()
	$"OutOfManaNotice".hide()

func card_selected_notice(display):
	if display == true:
		$"PickEnemyNotice".show()
	elif display == false:
		$"PickEnemyNotice".hide()
	else:
		$"PickEnemyNotice".hide()

func show_out_of_mana_tip():
	hide_all_visible_notices()
	$"OutOfManaNotice".show()
	$"AnimationPlayer".play("OutOfManaNotice")

func show_card_tip():
	hide_all_visible_notices()
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
