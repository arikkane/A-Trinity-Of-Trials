extends Control
@export var game_scene_path : String = "res://scenes.combat.tscn"
@export var settings_scene_path : String = "res://SettingsMenu.tscn"

func _ready() -> void:
	setup_menu_ui()
	
	
func setup_menu_ui():
	#creates the container to hold all the buttons
	var menu_container = VBoxContainer.new()
	add_child(menu_container)
	
	#centers the container to the middle of the screen
	menu_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_theme_constant_override("seperation", 15)
	
	#creates all the buttons
	var play_button = Button.new()
	play_button.text = "Play"
	play_button.pressed.connect(_on_play_button_pressed)
	#var play_button = create_button("Play Game", _on_play_button_pressed())
	#var settings_button = create_button("Settings", _on_settings_button_pressed)
	#var exit_button = create_button("Exit", _on_exit_button_pressed)
	
	
	#adds buttons to the containers
	menu_container.add_child(play_button)
	#menu_container.add_child(settings_button)
	#menu_container.add_child(exit_button)
	print("done") 
	
	play_button.grab_focus()
	
	
#function that switches to the initial combat scene of the game
func _on_play_button_pressed():
	get_tree().change_scene_to_file(game_scene_path)
	
#fucntion that switches to the settings scene
func _on_settings_button_pressed():
	get_tree().change_scene_to_file(settings_scene_path)
	
#function that closes the program
func _on_exit_button_pressed():
	get_tree().quit()
	
func create_button(text : String, callback : Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200,150)
	button.pressed.connect(callback)
	return button
	
