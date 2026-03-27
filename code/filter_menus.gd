extends HBoxContainer

func _ready():
	$"FilterType".custom_minimum_size = Vector2(150, 60)
	$"FilterBy".custom_minimum_size = Vector2(150, 60)
	GameManager.DeckDisplayUI.filter_type = $"FilterType".get_selected_id()
	GameManager.DeckDisplayUI.filter_by = $"FilterBy".get_selected_id()
	GameManager.DeckDisplayUI.connect_filter_menu_signals()
