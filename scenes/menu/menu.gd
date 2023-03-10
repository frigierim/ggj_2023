extends Control

func _ready():
	
	randomize()
	
	#$Version/GameVersion.text = ProjectSettings.get_setting("application/config/version")
	#$Version/GodotVersion.text = "Godot %s" % Engine.get_version_info().string
	# needed for gamepads to work
	$VBoxContainer/PlayButton.grab_focus()
	if OS.has_feature('HTML5'):
		$VBoxContainer/ExitButton.queue_free()

	# Temporarily disabled, tile visibility cannot be restored across runs
	#$VBoxContainer/ResumeButton.disabled = not GameStatus.is_savegame_present()
	
	Audio.play_music("res://assets/audio/dungeon_ambient_1.ogg", false)


func _on_PlayButton_pressed() -> void:
	#Game.change_scene("res://scenes/CombatScene/CombatScene.tscn", params)
	Game.change_scene("res://scenes/tilemap/TileMapScene.tscn")


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		yield(transitions.anim, "animation_finished")
		yield(get_tree().create_timer(0.3), "timeout")
	get_tree().quit()


func _on_ResumeButton_pressed():
	GameStatus.load_gamestate()
	Game.change_scene("res://scenes/tilemap/TileMapScene.tscn")
	
