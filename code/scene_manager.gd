extends Node

# This script is autoloaded (Globals), handles scene transitions
func change_scene(scene_path: String) -> void:
	var scene_container = get_node("/root/Main/SceneContainer")

	for child in scene_container.get_children():
		if child.scene_file_path == "res://scenes/combat.tscn" and child.has_method("combat_end"):
			child.combat_end()
		child.queue_free()  # no defer needed if you defer the add below

	# Wait a frame so queue_free finishes before adding new scene
	await get_tree().process_frame

	var new_scene = load(scene_path).instantiate()
	scene_container.add_child(new_scene)

	if scene_path == "res://scenes/main_menu.tscn":
		get_node("/root/Main/UIOverlay").visible = false
	else:
		get_node("/root/Main/UIOverlay").visible = true

	print("Changed scene to:", scene_path)
