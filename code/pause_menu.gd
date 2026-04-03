extends Control

func _ready():
	hide()
	$AnimationPlayer.play("RESET") #reset menu animation states  

# resume the game
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

#pause the game
func pause():
	print("Paused")
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

# Handles pausing/unpausing.
func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	pass # this will be replaced when quitting is added
	# get_tree.quit()

func _process(delta):
	testEsc() #listen for esc
