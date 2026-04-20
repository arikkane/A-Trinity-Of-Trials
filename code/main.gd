extends Node

var initialized = false
var filter_UI = ColorRect

func _ready() -> void:
	if initialized:
		print("⚠️ Main already initialized — skipping")
		return
	
	initialized = true
	
	print("Main scene loaded")

	SceneManager.SceneContainer = $"SceneContainer"
	SceneManager.SceneTransition = $"SceneTransition"
	GameManager.UIOverlay = $"UIOverlay"
	GameManager.Main = self
	$"UIOverlay".hide_ui()
	$"SceneTransition".hide()
	
	setup_colorblind_filter()
	load_and_apply_colorblind_filter()
	SceneManager.change_scene("res://scenes/main_menu.tscn")
	
	
	
func setup_colorblind_filter():
	filter_UI = ColorRect.new()
	filter_UI.name = "ColorRect"
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
	
func load_and_apply_colorblind_filter():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var mode = config.get_value("video", "colorblind_mode", 0)
		apply_global_colorblind_mode(mode)
		
		
func apply_global_colorblind_mode(index: int):
	if filter_UI:
		if index == 0:
			filter_UI.visible = false
		else:
			filter_UI.visible = true
			filter_UI.material.set_shader_parameter("mode", index)
