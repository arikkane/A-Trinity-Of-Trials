extends CanvasLayer

var transition_type = {
	"square_sweep": preload("res://scenes/animation_shaders/square_sweep.gdshader"),
	"fade": preload("res://scenes/animation_shaders/fade.gdshader"),
	"horizontal_sweep": preload("res://scenes/animation_shaders/horizontal_sweep.gdshader"),
	"diagonal_sweep": preload("res://scenes/animation_shaders/diagonal_sweep.gdshader"),
}

@onready var animation: AnimationPlayer = $TransitionAnim
@onready var transition: ColorRect = $TransitionColor

# This is the scene transition script.
# Call scene transitions using "SceneManager.SceneTransition.transition_scene()"
# Pass a argument to it to specify the transition type (see above), e.g. SceneManager.SceneTransition.transition_scene("square_sweep")
# You don't need to specify a transition type, but it'll default to square_sweep if you don't

func transition_scene(type: String = "square_sweep"):
	#Check to see if transition type exists; if it doesn't, default to square sweep.
	if transition_type.has(type):
		if not transition.material.shader == transition_type[type]:
			transition.material.shader = transition_type[type]
	else:
		print("Invalid transition type specified; using square sweep")
		transition.material.shader = transition_type["square_sweep"]
		
	show()
	animation.play("transition_out")
	await animation.animation_finished
	#animation.play("RESET")
	return

func detransition_scene(type: String = "square_sweep"):
	#Check to see if transition type exists; if it doesn't, default to square sweep.
	if transition_type.has(type):
		if not transition.material.shader == transition_type[type]:
			transition.material.shader = transition_type[type]
	else:
		print("Invalid transition type specified; using square sweep")
		transition.material.shader = transition_type["square_sweep"]
	
	#animation.play_backwards("fade")
	animation.play("transition_in")
	await animation.animation_finished
	hide()
	return
