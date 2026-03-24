extends CanvasLayer

func update_gold():
	$"GoldContainer/Label".text = str(GameManager.PlayerGold)
