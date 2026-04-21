extends Control

const SAVE_PATH = "user://settings.cfg"

var master_slider: HSlider
var volume_label: Label
var fullscreen_check: CheckButton
var text_animation: CheckButton
var save_button: Button
var colorblind_check: OptionButton
var filter_UI: ColorRect
enum BlindMode {NORMAL = 0, PROTANTOPIA = 1, DEUTERANOPIA = 2, TRITANOPIA = 3}
var back_button = Button
var return_path : String = ""




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_colorblind_filter()
	setup()
	load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	#creates background panel
	var panel = PanelContainer.new()
	add_child(panel)
	panel.custom_minimum_size = Vector2(600,500)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(vbox)
	
	#settings menu title creation
	var title = Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	#video and resolution check
	var video_label = Label.new()
	video_label.text = "Video"
	vbox.add_child(video_label)
	
	fullscreen_check = CheckButton.new()
	fullscreen_check.text = "Fullscreen Mode"
	fullscreen_check.toggled.connect(fullscreen_toggle)
	vbox.add_child(fullscreen_check)
	
	#audio creation and check
	var audio_label = Label.new()
	audio_label.text = "Master Volume"
	vbox.add_child(audio_label)
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	master_slider = HSlider.new()
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = .01
	master_slider.value = 0.6
	master_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#master_slider.value_changed.connect(master_volume_control)
	vbox.add_child(master_slider)
	
	volume_label = Label.new()
	volume_label.custom_minimum_size = Vector2(50,0)
	volume_label.text = str(round(master_slider.value*100)) +"%"
	hbox.add_child(volume_label)
	
	#color blind mode option button
	colorblind_check = OptionButton.new()
	colorblind_check.add_item("Normal")
	colorblind_check.add_item("Protanopia")
	colorblind_check.add_item("Deuteranopia")
	colorblind_check.add_item("Tritanopia")
	colorblind_check.item_selected.connect(update_mode)
	vbox.add_child(colorblind_check)
	
	text_animation = CheckButton.new()
	text_animation.text = "Animated Text"
	text_animation.button_pressed = true
	text_animation.toggled.connect(animated_text_toggle)
	vbox.add_child(text_animation)
	
	#creates a save button for the settings UI
	save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(save_settings)
	vbox.add_child(save_button)
	
	#creates an exit button to go back to main menu or game
	back_button = Button.new()
	back_button.text = "Back"
	back_button.pressed.connect(_on_back_button_clicked)
	vbox.add_child(back_button)
	
	
	#function that creates and setsup a useable colorblind filter for 3
	#different forms of color blindness
func setup_colorblind_filter():
	filter_UI = ColorRect.new()
	filter_UI.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	filter_UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filter_UI.visible = false
	
	var mat = ShaderMaterial.new()
	
	mat.shader = load("res://scenes/colorblind_shader.gdshader")
	filter_UI.material = mat
	
	var canvas = CanvasLayer.new()
	canvas.name = "FilterCanvas"
	canvas.layer = 100
	add_child(canvas)
	canvas.add_child(filter_UI)
	update_mode(colorblind_check.selected if colorblind_check else 0)
	
func update_mode(index: int):
	if filter_UI and filter_UI.material:
		filter_UI.visible = (index != BlindMode.NORMAL)
		if filter_UI.visible:
			filter_UI.material.set_shader_parameter("mode", index)
	
	if GameManager.Main and GameManager.Main.has_method("apply_global_colorblind_mode"):
		GameManager.Main.apply_global_colorblind_mode(index)

#toggles window to be either fullscreen or windowed mode
func fullscreen_toggle(button_pressed: bool):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#toggles the resolution according to user setting
func resolution_toggle(index: int):
	var rest_text = $Video/ResolutionButton.get_item_text(index)
	var new_size = Vector2i(1920,1080)
	DisplayServer.window_set_size(new_size)

#volume control function that edits volume according to decibels
func master_volume_control(value: float):
	AudioManager.set_master_volume(value)
	volume_label.text = str(round(value*100)) +"%"

func animated_text_toggle(button_pressed: bool):
	if button_pressed:
		GameManager.AnimatedText = true
	else:
		GameManager.AnimatedText = false
	
	
	
func _on_back_button_clicked():
	#if ResourceLoader.exists(return_path):
		#get_tree().change_scene_to_file(return_path)
		#self.queue_free()
	#else:
		#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if SceneManager.previous_path != "":
		SceneManager.change_scene(SceneManager.previous_path)
	else:
		SceneManager.change_scene("res://scenes/main_menu.tscn")
		
#saves current settings to a config file
func save_settings():
	#stores video settings
	var config = ConfigFile.new()
	var mode = fullscreen_check.button_pressed
	config.set_value("video", "fullscreen", mode)
	
	#stores audio settings
	var bus_idx = AudioServer.get_bus_index("Master")
	var volume = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	config.set_value("audio", "master_volume", volume)
	config.save("user://settings.cfg")
	
	#stores color blind settings
	var color_mode = colorblind_check.selected
	config.set_value("video", "colorblind_mode", color_mode)
	config.save("user://settings.cfg")
	
	
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
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_check.button_pressed = is_fullscreen
	
	#apply audio settings
	var volume = config.get_value("audio","master_volume", .5)
	AudioManager.set_master_volume(volume)
	
	#apply color blind mode settings
	var colorblind_mode = config.get_value("video","colorblind_mode", 0)
	update_mode(colorblind_mode)
	
	#update UI settings
	fullscreen_check.button_pressed = is_fullscreen
	master_slider.value = volume
	colorblind_check.selected = colorblind_mode
	
