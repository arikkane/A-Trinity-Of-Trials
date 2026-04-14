extends Node

@export var game_scene_path : String = "res://scenes/ClassSelection.tscn"
@export var settings_scene_path : String = "res://scenes/SettingsMenu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_menu_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func setup_menu_ui():
	#creates the container to hold all the buttons
	var menu_container = VBoxContainer.new()
	add_child(menu_container)
	
	#centers the container to the middle of the screen
	menu_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_theme_constant_override("seperation", 15)
	
	#creates all the buttons
	var play_button = create_button("Play Game", _on_play_button_pressed)
	var settings_button = create_button("Settings", _on_settings_button_pressed)
	var exit_button = create_button("Exit", _on_exit_button_pressed)
	
	
	#adds buttons to the containers
	menu_container.add_child(play_button)
	menu_container.add_child(settings_button)
	menu_container.add_child(exit_button)
	print("done") 
	
	play_button.grab_focus()
	

#function that switches to the initial combat scene of the game
func _on_play_button_pressed():
	##get_tree().change_scene_to_file(game_scene_path)
	SceneManager.change_scene(game_scene_path)
	
#fucntion that switches to the settings scene
func _on_settings_button_pressed():
	var settings_scene = load("res://scenes/SettingsMenu.tscn").instantiate()
	settings_scene.return_path = "res://scenes.main_menu.tscn"
	get_tree().root.add_child(settings_scene)
	self.queue_free()
	#get_tree().change_scene_to_file(settings_scene_path)
	
#function that closes the program
func _on_exit_button_pressed():
	get_tree().quit()
	
func create_button(text : String, callback : Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200,50)
	button.pressed.connect(callback)
	return button
