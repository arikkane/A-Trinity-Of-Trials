extends Control

var idleTexture: Texture2D = preload("res://sprites/map/battle_icon.png")
var hoverTexture: Texture2D = preload("res://sprites/map/battle_icon_hovering.png")

var row_index
var is_empty = true
var room_type
var connected_nodes: Array[Control]
var connecting_lines: Array[Line2D]
var line_offset_radius = 48

func _ready() -> void:
	connected_nodes.clear()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_position():
	var column = get_parent()
	global_position = Vector2(column.custom_minimum_size.x*column.column_index+column.get_parent().column_width/2-size.x/2, column.get_parent().column_vertical_offset+column.get_parent().column_height/GameManager.MapGridHeight * row_index+size.y/2)

func create_path_line(next_node):
	var new_line = Line2D.new()
	new_line.default_color = "#75503f"
	new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_line.width = 6
	var p1 = Vector2($"NodeTexture".size.x/2, $"NodeTexture".size.y/2)
	var p2 = Vector2(next_node.global_position.x-global_position.x+$"NodeTexture".size.x/2, next_node.global_position.y-global_position.y+abs($"NodeTexture".size.y/2))
	var direction = (p2-p1).normalized()
	p1 += direction * line_offset_radius
	p2 -= direction * line_offset_radius
	new_line.add_point(p1)
	new_line.add_point(p2)
	add_child(new_line)
	connecting_lines.append(new_line)

func _on_mouse_entered():
	if $"NodeTexture".texture != hoverTexture:
		$"NodeTexture".texture = hoverTexture

func _on_mouse_exited():
	if $"NodeTexture".texture != idleTexture:
		$"NodeTexture".texture = idleTexture
