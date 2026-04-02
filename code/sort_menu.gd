extends HBoxContainer

func _ready():
	$"SortType".custom_minimum_size = Vector2(150, 60)
	$"SortBy".custom_minimum_size = Vector2(150, 60)
	GameManager.DeckDisplayUI.sort_type = $"SortType".get_selected_id()
	GameManager.DeckDisplayUI.sort_by = $"SortBy".get_selected_id()
