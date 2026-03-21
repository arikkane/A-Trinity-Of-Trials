extends Node

#this script handles the randomized map generation

#variables and arrays that store the scenes and nodes for path generation
var map_grid_column: PackedScene = preload("res://scenes/map_grid_column.tscn")
var map_node: PackedScene = preload("res://scenes/map_node.tscn")
var map_grid_columns: Array[Control]
var boss_node
var map_texture: TextureRect

var column_width
var column_height
var column_vertical_offset

#flag that prevents user from moving to a new room before finishing the current encounter
var room_select_lock = false

func _ready() -> void:
	randomize()
	map_texture = $"TextureRect"
	#sets the dimensions of the columns
	column_width = (map_texture.size.x-319)/GameManager.MapGridWidth
	column_height = 704
	column_vertical_offset = 192
	
	init_map_grid_columns()
	init_node_paths()
	clear_empty_nodes()
	roll_room_types()
	generate_boss_node()

#--------------------------------------
# This function initializes the columns
# for the node generation grid
#--------------------------------------
func init_map_grid_columns():
	for i in range(GameManager.MapGridWidth):
		var new_column = map_grid_column.instantiate()
		new_column.column_index = i
		#adds the new column to the map_grid_columns array
		map_grid_columns.append(new_column)
		add_child(new_column)
		#applies the dimensions and position for the column
		new_column.init_container_transform()
		#generates the empty nodes for the full column
		new_column.init_empty_nodes()

#----------------------------------------------------------------
# This function randomly generates the paths for the current run. 
# Generates the paths one at a time, ensuring all map nodes are 
# within the grid and the paths do not cross
#----------------------------------------------------------------
func init_node_paths():
	#creates 6 paths
	for i in range(6):
		#generates a random starting position for the current path
		var start_pos = randi() % GameManager.MapGridHeight
		#makes sure that the starting point for the first and second path are not the same, ensuring atleast two starting node options
		if i == 1 and map_grid_columns[0].existing_node_flags[start_pos] == 1:
			#randomly generates a new starting point until it is not the same as the first path starting point
			while map_grid_columns[0].existing_node_flags[start_pos] != 1:
				start_pos = randi() % GameManager.MapGridHeight
		#sets the current node to the starting position
		var current_node = map_grid_columns[0].map_nodes[start_pos]
		current_node.is_empty = false
		#for every column up to the boss node
		for j in range(1,GameManager.MapGridWidth):
			#generates the next position of the path based on the 3 closest nodes in the next column
			var next_position = randi() % 3 + (current_node.row_index-1)
			#makes sure that paths cant cross
			while(map_grid_columns[j-1].check_for_crossing(current_node.row_index, next_position)):
				next_position = randi() % 3 + (current_node.row_index-1)
			#ensures that the next position is not outside of the map grid
			next_position = clamp(next_position, 0, GameManager.MapGridHeight-1)
			
			#gets the next node based on the generated next position
			var next_node = map_grid_columns[j].map_nodes[next_position]
			#sets the flag for the next node to 1
			map_grid_columns[j].existing_node_flags[next_position] = 1
			#prevents duplicate nodes in the forward connecting array for the current node
			if not next_node in current_node.forward_connected_nodes:
				current_node.forward_connected_nodes.append(next_node)
			#renders the line between the current and next node
			current_node.create_path_line(next_node)
			#stores the positions of the current and next nodes to the connections array, used in cross prevention
			map_grid_columns[j-1].connections.append(Vector2(current_node.row_index, next_position))
			
			#adds the current node to the next node backwards connection array
			next_node.backward_connected_nodes.append(current_node)
			next_node.is_empty = false
			current_node = next_node

#-------------------------------------------------
# This function rolls the room types for each node
# using weights and specific generation rules
#-------------------------------------------------
func roll_room_types():
	var room_weights = {
			GameManager.RoomTypes.Combat: 50,
			GameManager.RoomTypes.Event: 35,
			GameManager.RoomTypes.Rest: 25,
			GameManager.RoomTypes.Shop: 20
		}
	for column in map_grid_columns:
		for node in column.map_nodes:
			#gets all the nodes in the paths leading to the current node
			var previous_nodes = node.get_prev_nodes()
			#print_previous_nodes(node, previous_nodes)
			
			#prevents nodes having their rooms rerolled multiple times
			if not node.room_type_rolled:
				#if not a starting node
				if not node.get_parent().column_index == 0:
					#creates a duplicate of the weights dictionary so that they can be adjusted for this specific node
					var weights = room_weights.duplicate()
					adjust_weights(node, previous_nodes, weights)
					#print_previous_nodes(node, previous_nodes)
					#print("weights:")
					#for weight in weights:
						#print(str(weight) + ": " + str(weights[weight]))]
					node.room_type = roll_room(weights)
				node.room_type_rolled = true
				node.update_sprite()

#------------------------------------------------------------
# This function adjusts the room weights for the current node
# ensuring that duplicate combat and event nodes are less 
# likely and that there can only be one rest every few nodes
# and one shop every few nodes
#------------------------------------------------------------
func adjust_weights(node, previous_nodes, weights):
	if not previous_nodes.is_empty():
		if type_in_last_n_rooms(node, previous_nodes, GameManager.RoomTypes.Combat, 1):
			weights[GameManager.RoomTypes.Combat] *= 0.3
		if type_in_last_n_rooms(node, previous_nodes, GameManager.RoomTypes.Event, 1):
			weights[GameManager.RoomTypes.Event] *= 0.3
		if type_in_last_n_rooms(node, previous_nodes, GameManager.RoomTypes.Shop, 3):
			weights[GameManager.RoomTypes.Shop] = 0
		if type_in_last_n_rooms(node, previous_nodes, GameManager.RoomTypes.Rest, 3):
			weights[GameManager.RoomTypes.Rest] = 0

#-----------------------------------------------
# This function checks if there is a node with a
# specific room type within the last n nodes
#-----------------------------------------------
func type_in_last_n_rooms(node, previous_nodes, type:GameManager.RoomTypes, n):
	var index = 0
	while index < previous_nodes.size() and node.get_parent().column_index - previous_nodes[index].get_parent().column_index <= n:
		if previous_nodes[index].room_type == type:
			return true
		index += 1
	return false

#-------------------------------------------------
# This function rolls for a specific room based on
# the provided weights
#-------------------------------------------------
func roll_room(weights):
	var total = 0
	#gets the total of all the weights
	for value in weights.values():
		total += value
	
	#rolls a random integer between 0 and the total-1
	var roll = randi_range(0, total-1)
	var cumulative = 0
	#adds the weight of each room in descending order until the cumulative value is greater than the roll number
	for key in weights.keys():
		cumulative += weights[key]
		if roll < cumulative:
			return key

#----------------------------------------------------------
# This function clears all the nodes that are not connected 
# through any of the generated paths
#----------------------------------------------------------
func clear_empty_nodes():
	for column in map_grid_columns:
		for i in range(column.map_nodes.size()-1, -1, -1):
			if column.map_nodes[i].is_empty:
				var deleting_node = column.map_nodes[i]
				column.map_nodes.erase(deleting_node)
				deleting_node.queue_free()

func generate_boss_node():
	boss_node = map_node.instantiate()
	boss_node.global_position = Vector2(2650, map_texture.size.y/2-boss_node.size.y/2)
	boss_node.row_index = GameManager.MapGridHeight/2
	add_child(boss_node)
	for node in map_grid_columns.back().map_nodes:
		node.create_path_line(boss_node)

#------------------ Debug Functions ------------------
func print_column_data():
	for column in map_grid_columns:
		column.print_transform_data()

func print_connected_nodes():
	print("map_grid_columns.size(): " + str(map_grid_columns.size()))
	for column in map_grid_columns:
		print("Column: " + str(column.column_index))
		print("--------------------------------------")
		for node in column.map_nodes:
			print("Position: " + str(node.position))
			print("Global Position: " + str(node.global_position))
			print("Row: " + str(node.row_index))
			print("is_empty: " + str(node.forward_connected_nodes.is_empty()))
			print("Forward Connected nodes: ")
			for conn_node in node.forward_connected_nodes:
				conn_node.print_grid_position()
			print("Backward Connected nodes: ")
			for conn_node in node.backward_connected_nodes:
				conn_node.print_grid_position()

func print_previous_nodes(current_node, previous_nodes):
	print("Current node:")
	current_node.print_grid_position()
	print("Previous nodes:")
	for node in previous_nodes:
		node.print_grid_position()
