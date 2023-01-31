extends Node

var _bg_music_player : AudioStreamPlayer

func _ready():
	_bg_music_player = AudioStreamPlayer.new()
	if _bg_music_player:
		# Keep background music running when paused
		_bg_music_player.pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().root.get_node("/root").call_deferred("add_child", _bg_music_player)
	
func play_music(resource, stop_existing : bool = true):
	var just_loaded : bool = false
	
	if _bg_music_player:
		if stop_existing:
			_bg_music_player.stop()
		
		if _bg_music_player.stream == null or \
			_bg_music_player.stream.resource_path != resource:
			just_loaded = true
			_bg_music_player.stream = load(resource)
			if _bg_music_player.stream.has_method("set_loop"):
				_bg_music_player.stream.set_loop(true)

		if stop_existing or just_loaded:
			_bg_music_player.play()
		
func play_sound(resource):
	var new_sound_player = AudioStreamPlayer.new()
	call_deferred("add_sound", new_sound_player, resource)
	
func on_sound_finished(player):
	get_tree().root.get_node("/root").remove_child(player)

func add_sound(new_sound_player, resource):
	if new_sound_player:
		get_tree().root.get_node("/root").add_child(new_sound_player)
		new_sound_player.stream = load(resource)
		new_sound_player.connect("finished", self, "on_sound_finished", [new_sound_player])
		new_sound_player.play()

