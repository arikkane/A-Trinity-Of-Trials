extends HBoxContainer

func _ready():
	$"FilterType".custom_minimum_size = Vector2(150, 60)
	$"FilterBy".custom_minimum_size = Vector2(150, 60)
	GameManager.DeckDisplayUI.connect_filter_menu_signals()
