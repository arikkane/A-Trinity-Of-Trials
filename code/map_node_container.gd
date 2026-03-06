extends Control

var container_index = 0

var map_node_scene: PackedScene = preload("res://scenes/map_node.tscn")
var column_nodes_flag: Array[int] = [0,0,0,0,0,0,0,0,0,0,0,0]
var column_nodes: Array[Control]

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

func init_container_transform():
	custom_minimum_size = Vector2(get_parent().map_texture.size.x/GameManager.MapGridWidth, 704)
	global_position = Vector2(get_parent().map_texture.size.x*container_index, 184)
	init_debug_border()

func add_node(new_node):
	column_nodes.append(new_node)
	add_child(new_node)

func get_node_at_position(index):
	for node in column_nodes:
		if node.row_position == index:
			return node

func update_node_positions():
	for node in column_nodes:
		node.update_position()

func print_column_nodes_flag():
	print(column_nodes_flag)

func init_debug_border():
	var stylebox_border = StyleBoxFlat.new()
	
	stylebox_border.set_border_width_all(4)
	stylebox_border.set_border_color(Color.RED)
	add_theme_stylebox_override("normal", stylebox_border)
