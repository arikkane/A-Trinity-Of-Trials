extends Node

var map_grid_column: PackedScene = preload("res://scenes/map_node_container.tscn")
var map_node: PackedScene = preload("res://scenes/map_node.tscn")
var map_grid_columns: Array[Control]
var boss_node
var map_texture: TextureRect

var column_width
var column_height
var column_vertical_offset

var room_select_lock = false

func _ready() -> void:
	randomize()
	map_texture = $"TextureRect"
	column_width = (map_texture.size.x-319)/GameManager.MapGridWidth
	column_height = 704
	column_vertical_offset = 192
	
	init_map_node_containers()
	init_map_nodes()
	clear_empty_nodes()
	generate_boss_node()
	generate_room_types()
	#print_connected_nodes()


func init_map_node_containers():
	for i in range(GameManager.MapGridWidth):
		var new_column = map_grid_column.instantiate()
		new_column.column_index = i
		map_grid_columns.append(new_column)
		add_child(new_column)
		new_column.init_container_transform()
		new_column.init_empty_nodes()

func init_map_nodes():
	for i in range(6):
		var start_pos = randi() % GameManager.MapGridHeight
		if i == 1 and map_grid_columns[0].existing_node_flags[start_pos] == 1:
			while map_grid_columns[0].existing_node_flags[start_pos] != 1:
				start_pos = randi() % GameManager.MapGridHeight
		var current_node = map_grid_columns[0].map_nodes[start_pos]
		current_node.is_empty = false
		for j in range(1,GameManager.MapGridWidth):
			var next_position = randi() % 3 + (current_node.row_index-1)
			while(map_grid_columns[j-1].check_for_crossing(current_node.row_index, next_position)):
				next_position = randi() % 3 + (current_node.row_index-1)
			next_position = clamp(next_position, 0, GameManager.MapGridHeight-1)
			var next_node = map_grid_columns[j].map_nodes[next_position]
			map_grid_columns[j].existing_node_flags[next_position] = 1
			if not next_node in current_node.connected_nodes:
				current_node.connected_nodes.append(next_node)
			current_node.create_path_line(next_node)
			map_grid_columns[j-1].connections.append(Vector2(current_node.row_index, next_position))
			next_node.is_empty = false
			current_node = next_node

func clear_empty_nodes():
	for column in map_grid_columns:
		for i in range(column.map_nodes.size()-1, -1, -1):
			print("is (" + str(column.column_index) + "," + str(column.map_nodes[i].row_index) + ") empty?")
			if column.map_nodes[i].is_empty:
				print("Deleting node (" + str(column.column_index) + "," + str(column.map_nodes[i].row_index) + ")...")
				var deleting_node = column.map_nodes[i]
				column.map_nodes.erase(deleting_node)
				deleting_node.queue_free()

func print_connected_nodes():
	for column in map_grid_columns:
		print("Column: " + str(column.column_index))
		print("--------------------------------------")
		for node in column.map_nodes:
			print("Position: " + str(node.position))
			print("Global Position: " + str(node.global_position))
			print("Row: " + str(node.row_index))
			print("is_empty: " + str(node.connected_nodes.is_empty()))
			print("Connected nodes: ")
			for conn_node in node.connected_nodes:
				print("(" + str(conn_node.get_parent().column_index) + "," + str(conn_node.row_index) + ")")

func generate_boss_node():
	#print("in generate_boss_node()")
	boss_node = map_node.instantiate()
	boss_node.global_position = Vector2(2650, map_texture.size.y/2-boss_node.size.y/2)
	boss_node.row_index = GameManager.MapGridHeight/2
	add_child(boss_node)
	for node in map_grid_columns.back().map_nodes:
		node.create_path_line(boss_node)

func generate_room_types():

func print_container_data():
	for container in map_grid_columns:
		container.print_transform_data()
