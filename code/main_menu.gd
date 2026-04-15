extends Control

func _ready() -> void:
	setup_menu_ui()

func setup_menu_ui():
	var menu_container = VBoxContainer.new()
	add_child(menu_container)
	menu_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_theme_constant_override("separation", 15)

	var play_button = _create_button("Play Game", _on_play_button_pressed)
	var settings_button = _create_button("Settings", _on_settings_button_pressed)
	var exit_button = _create_button("Exit", _on_exit_button_pressed)

	menu_container.add_child(play_button)
	menu_container.add_child(settings_button)
	menu_container.add_child(exit_button)

	play_button.grab_focus()

func _on_play_button_pressed():
	SceneManager.change_scene("res://scenes/ClassSelection.tscn")

func _on_settings_button_pressed():
	SceneManager.change_scene("res://scenes/SettingsMenu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _create_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200, 50)
	button.pressed.connect(callback)
	return button

