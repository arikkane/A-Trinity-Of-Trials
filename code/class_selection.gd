extends Control

@onready var description_label = $DescriptionLabel
@onready var seed_toggle = $SeedButton
@onready var seed_input = $SeedInput

var default_description := ""

# Called when scene loads
func _ready():
	print("_ready running")
	AudioManager.play_music_track("main_menu")
	description_label.text = default_description
# ----------------------------
# BUTTON PRESSED FUNCTIONS
# ----------------------------

func _on_gundam_pressed():
	start_game(GameManager.PlayerClass.GUNDAM)
	print("class selected mech")

func _on_mage_pressed():
	start_game(GameManager.PlayerClass.HEXTECHMAGE)
	print("class selected mage")

func _on_creature_pressed():
	start_game(GameManager.PlayerClass.CREATURE)
	print("class selected alien")


# ----------------------------
# START GAME
# ----------------------------

func start_game(selected_class):
	print("Selected class: ", selected_class)
	AudioManager.play_sfx("menuclick2")
	randomize()
	
	if seed_toggle.button_pressed == false:
		pass
	elif seed_toggle.button_pressed == true and !seed_input.text.is_valid_float(): #if seed contains numbers, hash it and then use that hash as a seed
		seed(seed_input.text.hash())
		print("Seed: " + str(seed_input.text.hash()))
		pass
	else:
		var selected_seed = seed_input.text.to_int()
		seed(selected_seed)
		print("Seed: " + str(selected_seed))
	
	# Setup player + deck
	GameManager.setup_class(selected_class)

# ----------------------------
# HOVER DESCRIPTIONS
# ----------------------------

func _on_gundam_mouse_entered() -> void:
	description_label.text = "Health: 120, Passive: Deal extra damage equal to your current block value."
	
func _on_gundam_mouse_exited() -> void:
	description_label.text = default_description


func _on_mage_mouse_entered() -> void:
	description_label.text = "Health: 70, Passive: Gain a damage buff when you play draw cards."

func _on_mage_mouse_exited() -> void:
	description_label.text = default_description


func _on_creature_mouse_entered() -> void:
	description_label.text = "Health: 100, Passive: Recover HP when you deal damage."

func _on_creature_mouse_exited() -> void:
	description_label.text = default_description


func _on_seed_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		seed_input.editable = true
	else:
		seed_input.text = ""
		seed_input.editable = false
