extends CanvasLayer

#should be called every time gold is gained or spent
func update_gold():
	$"GoldContainer/Label".text = str(GameManager.PlayerGold)

#should be called every time the players current hp or max hp is changed
func update_health():
	$"HealthContainer/Label".text = str(GameManager.PlayerHP) + "/" + str(GameManager.PlayerMaxHP)
