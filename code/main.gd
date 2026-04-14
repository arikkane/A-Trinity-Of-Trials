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
	GameManager.UIOverlay = $"UIOverlay"
	$"UIOverlay".hide_ui()
	GameManager.Main = self
	
	SceneManager.change_scene("res://scenes/main_menu.tscn")
	
func setup_colorblind_filter():
	filter_UI = ColorRect.new()
	filter_UI.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	filter_UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filter_UI.visible = false
	
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	
	mat.shader = shader
	filter_UI.material = mat
	
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	canvas.add_child(filter_UI)
	
func apply_global_colorblind_mode(index: int):
	var filter = get_node_or_null("FilterCanvas/ColorRect")
	if filter:
		if index == 0:
			filter.visible = false
		else:
			filter.visible = true
			filter.material.set_shader_parameter("mode", index)
