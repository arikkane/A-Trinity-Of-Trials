extends Node2D

#this script handles the randomized map generation

#variables and arrays that store the scenes and nodes for path generation
var map_grid_column: PackedScene = preload("res://scenes/map_grid_column.tscn")
var map_node: PackedScene = preload("res://scenes/map_node.tscn")
var map_grid_columns: Array[Control] = []
var boss_node
var map_texture: TextureRect

var map_generated: bool = false
var map_selected_path: Array = []     # stores clicked nodes as [column,row]
var map_available_nodes: Array = []   # stores selectable nodes as [column,row]


var column_width
var column_height
var column_vertical_offset

#flag that prevents user from moving to a new room before finishing the current encounter
var map_lock = false

var used_combat_encounters: Dictionary = {}
var used_event_encounters: Dictionary = {}

func _ready() -> void:
	map_texture = $"TextureRect"
	AudioManager.play_music_track("map")
	column_width = (map_texture.size.x - 319) / GameManager.MapGridWidth
	column_height = 704
	column_vertical_offset = 192

	init_map_grid_columns()

	if GameManager.map_generated:
		restore_saved_map()
		restore_map_progress()
	else:
		randomize()
		init_node_paths()
		clear_empty_nodes()
		roll_room_types()
		generate_boss_node()
		save_generated_map()
		initialize_starting_nodes()
		GameManager.map_generated = true
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
		current_node.is_path_option = true
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
				if node.get_parent().column_index == 0:
					node.room_type = GameManager.RoomTypes.Combat
				else:
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
# through any of the generated paths, as well as connects
# the node clicked signal to the input handling function
#----------------------------------------------------------
func clear_empty_nodes():
	for column in map_grid_columns:
		for i in range(column.map_nodes.size()-1, -1, -1):
			if column.map_nodes[i].is_empty:
				var deleting_node = column.map_nodes[i]
				column.map_nodes.erase(deleting_node)
				deleting_node.queue_free()
			else:
				column.map_nodes[i].node_clicked.connect(_on_map_node_clicked)

#--------------------------------------------------------
# This function generates the boss node at the end of the
# map, along with connecting the end of each of the paths
# to the boss node
#--------------------------------------------------------
func generate_boss_node():
	boss_node = map_node.instantiate()
	boss_node.global_position = Vector2(2650, map_texture.size.y/2-boss_node.size.y/2)
	boss_node.row_index = GameManager.MapGridHeight/2
	boss_node.room_type = GameManager.RoomTypes.Boss
	boss_node.update_sprite()
	add_child(boss_node)
	boss_node.node_clicked.connect(_on_map_node_clicked)
	for node in map_grid_columns.back().map_nodes:
		node.forward_connected_nodes.append(boss_node)
		node.create_path_line(boss_node)

#-----------------------------------------------------------
# This event handling function is called whenever a map node 
# that is a valid path option is clicked on
#-----------------------------------------------------------
func _on_map_node_clicked(node: Control):
	if map_lock:
		return

	if not node.is_path_option:
		return

	var room_data = null

	match node.room_type:
		GameManager.RoomTypes.Combat:
			room_data = roll_combat_encounter()
		GameManager.RoomTypes.Event:
			room_data = roll_event_variation()
		GameManager.RoomTypes.Rest:
			room_data = init_rest_room()
		GameManager.RoomTypes.Shop:
			room_data = init_shop_room()
		GameManager.RoomTypes.Boss:
			room_data = init_boss_room()

	# Save clicked node
	save_map_progress(node)

	EventBus.emit_signal("map_node_selected", node)
	EventBus.emit_signal("room_entered", room_data)

	match node.room_type:
		GameManager.RoomTypes.Combat:
			EventBus.emit_signal("combat_started", room_data)
		GameManager.RoomTypes.Event:
			EventBus.emit_signal("event_started", room_data)
		GameManager.RoomTypes.Rest:
			EventBus.emit_signal("rest_started", room_data)
		GameManager.RoomTypes.Shop:
			EventBus.emit_signal("shop_started", room_data)
		GameManager.RoomTypes.Boss:
			EventBus.emit_signal("boss_started", room_data)

	map_lock = true
	print("map_lock:", map_lock)
	print("room_data:", room_data)
	hide_map()

#------------------------------------------------
# This function gets the weights from each combat
# encounter variation and rolls for one
#------------------------------------------------
func roll_combat_encounter():
	print("in roll_combat_encounter")
	#loads all the resources in the data/rooms/combat folder
	var combat_encounter_variations = get_all_room_variation_tres(GameManager.RoomTypes.Combat)
	#if resources were successfully loaded
	if combat_encounter_variations:
		#adds all the weights together
		var total = 0
		for variation in combat_encounter_variations:
			if variation.id in used_combat_encounters:
				#lowers the weight relative to how many times that combat variation was used
				variation.gen_weight /= used_combat_encounters[variation.id]
			total += variation.gen_weight
		
		var roll = randi_range(0, total-1)
		var cumulative = 0
		#adds each weight to cumulative, checking to see if cumulative is greater than roll each time
		for variation in combat_encounter_variations:
			cumulative += variation.gen_weight
			if roll < cumulative:
				if variation.id in used_combat_encounters:
					used_combat_encounters[variation.id] += 1
				else:
					used_combat_encounters[variation.id] = 2
				return variation
	else:
		print("Error: Failed to load combat_data resources")
		return null

#-----------------------------------------------
# This function gets the weights from each event
# variation and rolls for one
#-----------------------------------------------
func roll_event_variation():
	print("in roll_event_variation")
	#loads all the resources in the data/rooms/event folder
	var event_variations = get_all_room_variation_tres(GameManager.RoomTypes.Event)
	#if resources were successfully loaded
	if event_variations:
		#adds all the weights together
		var total = 0
		for variation in event_variations:
			if variation.id in used_event_encounters:
				#lowers the weight relative to how many times that event variation was used
				variation.gen_weight /= used_event_encounters[variation.id]
			total += variation.gen_weight
		
		var roll = randi_range(0, total-1)
		var cumulative = 0
		#adds each weight to cumulative, checking to see if cumulative is greater than roll each time
		for variation in event_variations:
			cumulative += variation.gen_weight
			if roll < cumulative:
				if variation.id in used_event_encounters:
					used_event_encounters[variation.id] += 1
				else:
					used_event_encounters[variation.id] = 2
				return variation
	else:
		print("Error: Failed to load combat_data resources")
		return null

#------------------------------------------
# This function loads the RestData resource
# from the data/rooms/rest folder
#------------------------------------------
func init_rest_room():
	print("in init_rest_room")
	var resource = ResourceLoader.load("res://data/rooms/rest/rest.tres")
	if resource:
		return resource
	else:
		print("Error: Failed to load rest room")
		return null

#------------------------------------------
# This function loads the ShopData resource
# from the data/rooms/shop folder
#------------------------------------------
func init_shop_room():
	print("in init_shop_room")
	var resource = ResourceLoader.load("res://data/rooms/shop/shop.tres")
	if resource:
		return resource
	else:
		print("Error: Failed to load shop room")
		return null

#--------------------------------------------
# This function loads the CombatData resource
# from the data/rooms/boss folder
#--------------------------------------------
func init_boss_room():
	print("in init_boss_room")
	var resource = ResourceLoader.load("res://data/rooms/boss/test_boss.tres")
	if resource:
		return resource
	else:
		print("Error: Failed to load boss room")
		return null

#-----------------------------------------------------
# This function gets all the RoomData resources files
# of the given room type, loads them all into an array
# then returns it
#-----------------------------------------------------
func get_all_room_variation_tres(room_type: GameManager.RoomTypes):
	var path = "res://data/rooms/"
	match room_type:
		GameManager.RoomTypes.Combat:
			path += "combat"
		GameManager.RoomTypes.Event:
			path += "event"
	#opens the data/rooms folder for the given room type
	var dir_access = DirAccess.open(path)
	var resources: Array[Resource]
	#if folder successfully opened
	if dir_access:
		#gets the filepath of all the files in the folder
		var file_list = dir_access.get_files()
		for file in file_list:
			file = path + "/" + file
			print(file)
			
			var resource: Resource = ResourceLoader.load(file)
			if resource:
				resources.append(resource)
		return resources
	else:
		return null

#----------------------------------------------------
# This function is called whenever a node is clicked,
# updating the next selectable path options
#----------------------------------------------------
func update_path_options(current_node):
	if not current_node.room_type == GameManager.RoomTypes.Boss:
		for node in current_node.get_parent().map_nodes:
			node.is_path_option = false
			node.update_sprite()
		for node in current_node.forward_connected_nodes:
			node.is_path_option = true
			node.update_sprite()

func hide_map():
	hide()
	$"MapCamera".enabled = false

func show_map():
	show()
	$"MapCamera".enabled = true

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
		
		
func initialize_starting_nodes():
	GameManager.map_available_nodes.clear()
	GameManager.map_selected_path.clear()

	for node in map_grid_columns[0].map_nodes:
		if node.is_path_option:
			GameManager.map_available_nodes.append([0, node.row_index])

func save_generated_map():
	GameManager.saved_map_paths.clear()
	GameManager.saved_room_types.clear()

	for col in map_grid_columns:
		for node in col.map_nodes:
			if not node.is_empty:
				var forward_connections = []
				for next_node in node.forward_connected_nodes:
					if next_node != null and next_node != boss_node:
						forward_connections.append([
							next_node.get_parent().column_index,
							next_node.row_index
						])

				GameManager.saved_map_paths.append({
					"column": col.column_index,
					"row": node.row_index,
					"forward": forward_connections
				})

				GameManager.saved_room_types.append({
					"column": col.column_index,
					"row": node.row_index,
					"room_type": node.room_type
				})
func restore_map_progress():
	map_lock = false

	# First disable all path options
	for column in map_grid_columns:
		for node in column.map_nodes:
			node.is_path_option = false

	# Mark previously selected nodes
	for saved_node in GameManager.map_selected_path:
		var col = saved_node[0]
		var row = saved_node[1]
		var node = get_node_by_grid(col, row)
		if node != null:
			node.is_path_option = false
			node.update_sprite()

	# Restore currently available next nodes
	for saved_node in GameManager.map_available_nodes:
		var col = saved_node[0]
		var row = saved_node[1]
		var node = get_node_by_grid(col, row)
		if node != null:
			node.is_path_option = true
			node.update_sprite()

	# Refresh all node sprites
	for column in map_grid_columns:
		for node in column.map_nodes:
			node.update_sprite()
			
func get_node_by_grid(column_index: int, row_index: int):
	if column_index < 0 or column_index >= map_grid_columns.size():
		return null

	for node in map_grid_columns[column_index].map_nodes:
		if node.row_index == row_index:
			return node

	return null
func restore_saved_map():
	# First mark everything empty
	for col in map_grid_columns:
		for node in col.map_nodes:
			node.is_empty = true
			node.forward_connected_nodes.clear()
			node.backward_connected_nodes.clear()
			node.is_path_option = false
			node.room_type_rolled = false

	# Restore existing nodes and room types
	for saved_room in GameManager.saved_room_types:
		var node = get_node_by_grid(saved_room["column"], saved_room["row"])
		if node != null:
			node.is_empty = false
			node.room_type = saved_room["room_type"]
			node.room_type_rolled = true

	# Remove empty nodes after marking real ones
	clear_empty_nodes()

	# Reconnect paths
	for saved_path in GameManager.saved_map_paths:
		var node = get_node_by_grid(saved_path["column"], saved_path["row"])
		if node == null:
			continue

		for conn in saved_path["forward"]:
			var next_node = get_node_by_grid(conn[0], conn[1])
			if next_node != null:
				if not next_node in node.forward_connected_nodes:
					node.forward_connected_nodes.append(next_node)
				if not node in next_node.backward_connected_nodes:
					next_node.backward_connected_nodes.append(node)
				node.create_path_line(next_node)

	# Rebuild boss node
	generate_boss_node()

	# Refresh sprites
	for col in map_grid_columns:
		for node in col.map_nodes:
			node.update_sprite()
			
func save_map_progress(current_node):
	var col = current_node.get_parent().column_index
	var row = current_node.row_index

	# Save chosen node in path history
	GameManager.map_selected_path.append([col, row])

	# Update path options visually in current map
	update_path_options(current_node)

	# Save the next selectable nodes
	GameManager.map_available_nodes.clear()

	if current_node.room_type != GameManager.RoomTypes.Boss:
		for next_node in current_node.forward_connected_nodes:
			GameManager.map_available_nodes.append([next_node.get_parent().column_index, next_node.row_index])
