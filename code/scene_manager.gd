extends Node

#This script is autoloaded via project settings Globals tab, contains the functionality for scene transitioning
var SceneContainer
var PrimaryScene

func change_scene(scene_path):
	print("changing scene to: " + scene_path)
	
	for child in SceneContainer.get_children():
		if child.scene_file_path == "res://scenes/combat.tscn":
			child.combat_end()
		remove_child(child)
		child.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	SceneContainer.add_child(new_scene)
	PrimaryScene = new_scene
	
	#makes the overlay invisible if the main menu scene is loaded
	if scene_path == "res://scenes/main_menu.tscn":
		get_node("/root/Main/UIOverlay").visible = false
	else:
		get_node("/root/Main/UIOverlay").visible = true

func print_all_scene_container_children():
	for child in SceneContainer.get_children():
		print(child.scene_file_path)

func load_room_data(data: RoomData):
	print("in load_room_data")
	PrimaryScene.init_room_data(data)
