extends Node

var map_grid_column: PackedScene = preload("res://scenes/map_node_container.tscn")
var map_node: PackedScene = preload("res://scenes/map_node.tscn")
var map_grid_columns: Array[Control]
var boss_node
var map_texture: TextureRect

var column_width
var column_height
var column_vertical_offset

func _ready() -> void:
	randomize()
	map_texture = $"TextureRect"
	column_width = (map_texture.size.x-319)/GameManager.MapGridWidth
	column_height = 704
	column_vertical_offset = 192
	
	init_map_node_containers()
	init_map_nodes()
	visualize_paths()
	print_connected_nodes()
	#generate_connecting_lines()
	#print_container_data()
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
	#repeat 6 times
		#pick a starting node, ensure first two are not the same
		#generate a path to the last column, with each node picking from the 3 closest nodes
	print("In init_map_nodes()")
	for i in range(6):
		var start_pos = randi() % GameManager.MapGridHeight
		print("i: " + str(i) + ", start_pos: " + str(start_pos))
		if i == 1 and map_grid_columns[0].existing_node_flags[start_pos] == 1:
			print("in second gen if statement")
			while map_grid_columns[0].existing_node_flags[start_pos] != 1:
				start_pos = randi() % GameManager.MapGridHeight
				print("start_pos: " + str(start_pos))
		var current_node = map_grid_columns[0].map_nodes[start_pos]
		for j in range(1,GameManager.MapGridWidth):
			current_node.is_empty = false
			var next_position = randi() % (current_node.row_index+1) + (current_node.row_index-1)
			next_position = clamp(next_position, 0, GameManager.MapGridHeight-1)
			var next_node = map_grid_columns[j].map_nodes[next_position]
			map_grid_columns[j].existing_node_flags[next_position] = 1
			if not next_node in current_node.connected_nodes:
				current_node.connected_nodes.append(next_node)
			current_node = next_node
	
	#generate_starting_nodes()
	#generate_next_column(map_node_containers[0], map_node_containers[1])
	#for container in map_node_containers:
		#container.update_node_positions()
	#generate_boss_node()

func visualize_paths():
	for column in map_grid_columns:
		for node in column.map_nodes:
			if node.is_empty:
				column.map_nodes.erase(node)
				node.queue_free()
			else:
				node.create_connecting_lines()

func print_connected_nodes():
	for column in map_grid_columns:
		print("Column: " + str(column.column_index))
		print("--------------------------------------")
		for node in column.map_nodes:
			print("Size: " + str(node.size))
			print("Position: " + str(node.position))
			print("Global Position: " + str(node.global_position))
			print("Row: " + str(node.row_index))
			print("Connected nodes: ")
			for conn_node in node.connected_nodes:
				print("(" + str(conn_node.get_parent().column_index) + "," + str(conn_node.row_index) + ")")

#func generate_starting_nodes():
	#for i in range(3):
		#var gen_flag = false
		#while not gen_flag:
			#var random_pos = randi() % (GameManager.MapGridHeight)
			#if map_node_containers[0].column_nodes_flag[random_pos] == 0:
				#map_node_containers[0].column_nodes_flag[random_pos] = 1
				#var new_node = map_node.instantiate()
				#new_node.row_index = random_pos
				#map_node_containers[0].add_node(new_node)
				#gen_flag = true
#
#func generate_next_column(current_col, next_col):
	#for current_node in current_col.column_nodes:
		#for i in range(current_node.row_index-1, current_node.row_index+2):
			#if i >= 0 and i < GameManager.MapGridHeight:
				#if next_col.column_nodes_flag[i] == 0:
					#next_col.column_nodes_flag[i] = randi()%2
					#if next_col.column_nodes_flag[i] == 1:
						#var new_node = map_node.instantiate()
						#new_node.row_index = i
						#current_node.connected_forward_nodes.append(new_node)
						#new_node.connected_backwards_nodes.append(current_node)
						#next_col.add_node(new_node)
				#elif next_col.column_nodes_flag[i] == 1:
					#var next_node = next_col.get_node_at_position(i)
					#current_node.connected_forward_nodes.append(next_node)
					#next_node.connected_backwards_nodes.append(current_node)
	#if not current_col.container_index == map_node_containers.size()-2:
		#generate_next_column(next_col, map_node_containers[next_col.container_index+1])
#
#func generate_connecting_lines():
	#for container in map_node_containers:
		#for node in container.column_nodes:
			#node.create_connecting_lines()
#
#func generate_boss_node():
	#print("in generate_boss_node()")
	##boss_node = map_node.instantiate()
	##add_child(boss_node)
	##for node in map_node_containers.back().column_nodes:
		##
#
#func print_connected_nodes():
	#for container in map_node_containers:
		#print("Column: " + str(container.container_index))
		#for node in container.column_nodes:
			#print("Position: (" + str(node.position.x) + "," + str(node.position.y) + ")")
			#print("	Row: " + str(node.row_index))
			#print("		Connected forward nodes:")
			#for connected_node in node.connected_forward_nodes:
				#print("			" + str(connected_node.row_index))
#
#func print_container_data():
	#for container in map_node_containers:
		#container.print_transform_data()
