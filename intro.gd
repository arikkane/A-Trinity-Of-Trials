extends Control

signal intro_done

func _ready():
	pass
	print("intro")
	$AnimationPlayer.play("fadein")
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("proudly_present")
	await get_tree().create_timer(2.0).timeout
	$AnimationPlayer.play_backwards("fadein")
	await get_tree().create_timer(2.0).timeout
	intro_done.emit()
	SceneManager.change_scene("res://scenes/main_menu.tscn")
