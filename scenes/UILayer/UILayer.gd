extends MarginContainer

onready var bar = $"%Bar"
onready var hp = $"%hp"

signal quit_pressed

func _process(delta):
	bar.value = GameStatus.player_hp
	hp.text = String(GameStatus.player_hp) + "/" + String(GameStatus.player_max_hp)


func _on_btnQuit_pressed():
	emit_signal("quit_pressed")
