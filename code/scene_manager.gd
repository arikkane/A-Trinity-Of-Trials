extends Node

# Autoloaded SceneManager

var SceneContainer: Node = null
var CurrentScene: Node = null
var previous_path: String = ""

# ----------------------------
# Change main scene (menus only)
# ----------------------------
func change_scene(scene_path: String):
	print("Changing scene to:", scene_path)
	print("⚠️ SCENE CHANGE CALLED:", scene_path)
	
	print_stack()
	if SceneContainer == null:
		push_error("SceneContainer is not set!")
		return

	# Remove ONLY the current scene
	if CurrentScene != null:
		previous_path = CurrentScene.scene_file_path
		CurrentScene.queue_free()
		await get_tree().process_frame
		
	# Load new scene
	var new_scene = load(scene_path).instantiate()
	SceneContainer.add_child(new_scene)
	CurrentScene = new_scene
	
	if "return_path" in CurrentScene:
		CurrentScene.return_path = previous_path

	print_current_scene()

# ----------------------------
# OPTIONAL: overlay scene (like combat, pause, etc.)
# ----------------------------
func add_overlay(scene_path: String) -> Node:
	print("Adding overlay:", scene_path)

	var scene = load(scene_path).instantiate()
	SceneContainer.add_child(scene)
	return scene

func remove_overlay(scene: Node):
	if scene:
		scene.queue_free()

# ----------------------------
# Debug
# ----------------------------
func print_current_scene():
	print("Current Scene:", CurrentScene)
