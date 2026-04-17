extends Control

@onready var description_label = $DescriptionLabel

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
	# Setup player + deck
	GameManager.setup_class(selected_class)

# ----------------------------
# HOVER DESCRIPTIONS
# ----------------------------

func _on_gundam_mouse_entered() -> void:
	description_label.text = "Health:120, Passive: Deal extra Damage equal to your current block value"
	
func _on_gundam_mouse_exited() -> void:
	description_label.text = default_description


func _on_mage_mouse_entered() -> void:
	description_label.text = "Health:70, Passive: gain a damage buff when you play draw cards"

func _on_mage_mouse_exited() -> void:
	description_label.text = default_description


func _on_creature_mouse_entered() -> void:
	description_label.text = "Health:100, Passive: recover hp when you deal damage"

func _on_creature_mouse_exited() -> void:
	description_label.text = default_description
