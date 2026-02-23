extends Node

func _ready() -> void:
	print("SceneManager loaded")

func change_scene(scene_path):
	print("...loading scene at path: " + scene_path)
	var scene_container = get_node("/root/Main/SceneContainer")
	
	for child in scene_container.get_children():
		child.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	scene_container.add_child(new_scene)
