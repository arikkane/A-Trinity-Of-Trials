extends CanvasLayer

#GUIText handles the card notices and the text container.

#---Text and Text Animation Variables--
const TEXT_ANIMATION_SPEED : int = 30
var animate_text : bool = false
var current_visible_characters : int = 0 
@onready var dtext = $"TextContainer/Info"

#Called when text is doing being animated.
signal text_animation_done

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
	if GameManager.AnimatedText == true:
		current_visible_characters = 0
		dtext.visible_characters = 0
		dtext.text = display_text
		animate_text = true
	
		await text_animation_done
		await get_tree().create_timer(0.4).timeout #is this bad coding practice?
	else:
		dtext.text = display_text
		await get_tree().create_timer(timer).timeout #is this bad coding practice?
	return

func _process(delta):
	if GameManager.AnimatedText == true:
		if animate_text == true:
			if dtext.visible_ratio < 1:
				dtext.visible_ratio += (1.0/dtext.text.length()) * (TEXT_ANIMATION_SPEED * delta)
				current_visible_characters = dtext.visible_characters
			else:
				animate_text = false
				text_animation_done.emit()
	else:
		dtext.visible_ratio = dtext.text.length()
