extends MarginContainer

onready var bar = $"%Bar"
onready var hp = $"%hp"

func _process(delta):
	bar.value = GameStatus.player_hp
	hp.text = String(GameStatus.player_hp) + "/" + String(GameStatus.player_max_hp)
