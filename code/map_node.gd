extends Control

var idleTexture: Texture2D = preload("res://sprites/temp_map_icon.png")
var hoverTexture: Texture2D = preload("res://sprites/temp_map_icon_hovering.png")

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if $"NodeTexture".texture != hoverTexture:
		$"NodeTexture".texture = hoverTexture

func _on_mouse_exited():
	if $"NodeTexture".texture != idleTexture:
		$"NodeTexture".texture = idleTexture
