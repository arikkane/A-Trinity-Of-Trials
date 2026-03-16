extends Control

var idleTexture: Texture2D = preload("res://sprites/temp_map_icon.png")
var hoverTexture: Texture2D = preload("res://sprites/temp_map_icon_hovering.png")

var row_index
var is_empty = true
var connected_nodes: Array[Control]
var connecting_lines: Array[Line2D]

func _ready() -> void:
	connected_nodes.clear()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

#func _draw():
	#if not is_empty:
		#for node in connected_nodes:
			#draw_line(get_global_rect().get_center(), node.get_global_rect().get_center(), Color.BLACK, 3.0, false)

func update_position():
	var column = get_parent()
	global_position = Vector2(column.custom_minimum_size.x*column.column_index-column.get_parent().column_width/2-size.x/2, column.get_parent().column_vertical_offset+column.get_parent().column_height/GameManager.MapGridHeight * row_index+size.y/2)

func create_connecting_lines():
	for conn_node in connected_nodes:
		var new_line = Line2D.new()
		var p1 = Vector2($"NodeTexture".size.x, $"NodeTexture".size.y/2)
		var p2 = Vector2(conn_node.global_position.x-global_position.x, conn_node.global_position.y-global_position.y+$"NodeTexture".size.y/2)
		new_line.add_point(p1)
		new_line.add_point(p2)
		new_line.width = 3
		add_child(new_line)
		connecting_lines.append(new_line)

func _on_mouse_entered():
	if $"NodeTexture".texture != hoverTexture:
		$"NodeTexture".texture = hoverTexture

func _on_mouse_exited():
	if $"NodeTexture".texture != idleTexture:
		$"NodeTexture".texture = idleTexture
