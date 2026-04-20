extends Node

@export var game_scene_path : String = "res://scenes/ClassSelection.tscn"
@export var settings_scene_path : String = "res://scenes/SettingsMenu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music_track("main_menu")
	GameManager.UIOverlay.hide_ui()
	setup_menu_ui()

func setup_menu_ui():
	var menu_container = VBoxContainer.new()
	add_child(menu_container)
	menu_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_theme_constant_override("separation", 15)

	var play_button = create_button("res://assets/UI&Charactors/new_game_icon.png",_on_play_button_pressed)
	var settings_button = create_button("res://assets/UI&Charactors/settings_con.png",_on_settings_button_pressed)
	var exit_button = create_button("res://assets/UI&Charactors/exit_icon.png",_on_exit_button_pressed)

	menu_container.add_child(play_button)
	menu_container.add_child(settings_button)
	menu_container.add_child(exit_button)

	play_button.grab_focus()
	

#function that switches to the initial combat scene of the game
func _on_play_button_pressed():
	SceneManager.change_scene(game_scene_path)
	
#fucntion that switches to the settings scene
func _on_settings_button_pressed():
	SceneManager.change_scene(settings_scene_path)
	
#function that closes the program
func _on_exit_button_pressed():
	get_tree().quit()

func create_button(icon: String,callback : Callable) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 50)
	button.icon = load(icon)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.pressed.connect(callback)
	return button
