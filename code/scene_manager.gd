extends Node

#This script is autoloaded via project settings Globals tab, contains the functionality for scene transitioning

func change_scene(scene_path):
	var scene_container = get_node("/root/Main/SceneContainer")
	
	for child in scene_container.get_children():
		if child.scene_file_path == "res://scenes/combat.tscn":
			child.combat_end()
		child.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	scene_container.add_child(new_scene)
	
	#makes the overlay invisible if the main menu scene is loaded
	if scene_path == "res://scenes/main_menu.tscn":
		get_node("/root/Main/UIOverlay").visible = false
	else:
		get_node("/root/Main/UIOverlay").visible = true
