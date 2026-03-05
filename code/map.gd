extends Node

var map_node_container: PackedScene = preload("res://scenes/map_node_container.tscn")
var map_node: PackedScene = preload("res://scenes/map_node.tscn")
var map_node_containers: Array[Control]
var boss_node
var map_texture: TextureRect

func _ready() -> void:
	randomize()
	map_texture = $"TextureRect"
	init_map_node_containers()
	init_map_nodes()

func init_map_node_containers():
	for i in range(GameManager.MapGridWidth):
		var new_container = map_node_container.instantiate()
		new_container.container_index = i
		map_node_containers.append(new_container)
		add_child(new_container)
		new_container.init_container_transform()

func init_map_nodes():
	generate_starting_nodes()
	generate_next_column(map_node_containers[0], map_node_containers[1])
	for container in map_node_containers:
		container.update_node_positions()
	#generate_boss_node()

func generate_starting_nodes():
	for i in range(3):
		var gen_flag = false
		while not gen_flag:
			var random_pos = randi() % (GameManager.MapGridHeight)
			if map_node_containers[0].column_nodes_flag[random_pos] == 0:
				map_node_containers[0].column_nodes_flag[random_pos] = 1
				var new_node = map_node.instantiate()
				new_node.row_position = random_pos
				map_node_containers[0].add_node(new_node)
				gen_flag = true

func generate_next_column(current_col, next_col):
	for current_node in current_col.column_nodes:
		for i in range(current_node.row_position-1, current_node.row_position+2):
			if i >= 0 and i < GameManager.MapGridHeight:
				if next_col.column_nodes_flag[i] == 0:
					next_col.column_nodes_flag[i] = randi()%2
					if next_col.column_nodes_flag[i] == 1:
						var new_node = map_node.instantiate()
						new_node.row_position = i
						current_node.connected_forward_nodes.append(new_node)
						new_node.connected_backwards_nodes.append(current_node)
						next_col.add_node(new_node)
				elif next_col.column_nodes_flag[i] == 1:
					var next_node = next_col.get_node_at_position(i)
					current_node.connected_forward_nodes.append(next_node)
					next_node.connected_backwards_nodes.append(current_node)
	if not current_col.container_index == GameManager.MapGridWidth-1:
		generate_next_column(next_col, map_node_containers[next_col.row_position+1])

#func generate_boss_node():
	#boss_node = map_node.instantiate()
	#add_child(boss_node)
	#for node in map_node_containers.back().column_nodes:
		#
