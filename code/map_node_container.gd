extends Control

var column_index = 0

var map_node_scene: PackedScene = preload("res://scenes/map_node.tscn")
var existing_node_flags: Array[int] = [0,0,0,0,0,0,0,0,0,0,0,0]
var connections: Array[Vector2]
var map_nodes: Array[Control]

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

func init_container_transform():
	custom_minimum_size = Vector2(get_parent().column_width, get_parent().column_height)
	global_position = Vector2(custom_minimum_size.x*column_index, get_parent().column_vertical_offset)

func init_empty_nodes():
	for i in range(GameManager.MapGridHeight):
		var new_node = map_node_scene.instantiate()
		new_node.row_index = i
		new_node.position = Vector2.ZERO
		map_nodes.append(new_node)
		add_child(new_node)
		new_node.update_position()

func check_for_crossing(current_position, target_position):
	for conn in connections:
		if (current_position < conn.x and target_position > conn.y) or (current_position > conn.x and target_position < conn.y):
			return true
	return false

#func get_node_at_position(index):
	#for node in column_nodes:
		#if node.row_index == index:
			#return node

#func update_node_positions():
	#for node in column_nodes:
		#node.update_position()

#func print_column_nodes_flag():
	#print(column_nodes_flag)

func print_transform_data():
	print("Column index: " + str(column_index))
	print("Custom Minimum Size" + str(custom_minimum_size))
	print("Position: (" + str(position.x) + "," + str(position.y) + ")")
