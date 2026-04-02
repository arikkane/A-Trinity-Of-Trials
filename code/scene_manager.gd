extends Node

#This script is autoloaded via project settings Globals tab, contains the functionality for scene transitioning
var SceneContainer
var PrimaryScene

func change_scene(scene_path):
	print("changing scene to: " + scene_path)
	var children = SceneContainer.get_children()
	
	for i in range(children.size()-1,-1,-1):
		if children[i].scene_file_path == "res://scenes/combat.tscn":
			children[i].combat_end()
		children[i].queue_free()
	
	# Wait a frame so queue_free finishes before adding new scene
	await get_tree().process_frame

	var new_scene = load(scene_path).instantiate()
	SceneContainer.add_child(new_scene)
	PrimaryScene = new_scene
	
	print_all_scene_container_children()
	
	#makes the overlay invisible if the main menu scene is loaded
	if scene_path == "res://scenes/main_menu.tscn":
		get_node("/root/Main/UIOverlay").visible = false
	else:
		get_node("/root/Main/UIOverlay").visible = true

#passes the room data resource for the loaded room into the scene
func load_room_data(data: RoomData):
	print("in load_room_data")
	PrimaryScene.init_room_data(data)

#------------------------Debug Function---------------------
func print_all_scene_container_children():
	print("\nCurrent scenes in scene container:")
	for child in SceneContainer.get_children():
		print(child.scene_file_path)
	print("")
	print("Changed scene to:", scene_path)
