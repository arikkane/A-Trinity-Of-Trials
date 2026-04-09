extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#function that creates the UI layout for a settings menu
func settings_UI():
	var canvas = CanvasLayer.new()
	var panel = PanelContainer.new()



#toggles window to be either fullscreen or windowed mode
func fullscreen_toggle(button_pressed: bool):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#toggles the resolution according to user setting
func resolution_toggle(index: int):
	var rest_text = $Video/ResolutionButton.get_item_text(index)
	var size = Vector2i(1920,1080)
	DisplayServer.window_set_size(size)

#volume control function that edits volume according to decibels
func master_volume_control(value: float):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
#saves current settings to a config file
func save_settings():
	#stores video settings
	var config = ConfigFile.new()
	var mode = DisplayServer.window_get_mode()
	config.set_value("video", "fullscreen", mode == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#stores audio settings
	var bus_idx = AudioServer.get_bus_index("Master")
	var volume = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	config.saet_value("audio", "master_volume", volume)
	config.save("user//settings.cfg")
	

#loads settings upon game opening
func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	#if there is no config file to pull from function stops
	if err != OK:
		return
	
	#apply video settings
	var is_fullscreen = config.get_value("video","fullscreen", false)
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#apply audio settings
	var volume = config.get_value("audio","master_volume", .8)
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	
	#update UI settings
	$FullscreenButton.button_pressed = is_fullscreen
	$volumeSlider.value = volume
	
