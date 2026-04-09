extends Control

# Called when scene loads
func _ready():
	print("_ready running")
	
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
