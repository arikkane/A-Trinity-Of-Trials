extends HBoxContainer

func _ready():
	$"SortType".custom_minimum_size = Vector2(150, 60)
	$"SortBy".custom_minimum_size = Vector2(150, 60)
	GameManager.DeckDisplayUI.connect_sort_menu_signals()
