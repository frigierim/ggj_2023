extends Node

const INITIAL_HP = 100

const SAVEFILE_PATH : String = "user://savegame.cfg"

export var light_rune_found : bool = false
export var player_hp : int = INITIAL_HP
export var weapon_level : int = 0
export var heal_level : int = 0
export var player_position : Vector2
var healing_progression : Array = [100, 110, 130, 170, 210, 260 ]

var _savefile = null

func _ready():
	reset(Vector2.ZERO)
	
func save_gamestate():
	_savefile = ConfigFile.new()
	if _savefile != null:
		if _savefile.load(SAVEFILE_PATH):
			light_rune_found = _savefile.get_value("light_rune_found", false)
			player_hp = _savefile.get_value("player_hp", INITIAL_HP) 
			weapon_level = _savefile.get_value("weapon_level", 0)
			heal_level = _savefile.get_value("heal_level", 0)
			player_position = _savefile.get_value("player_position", Vector2(0,0))
			
func is_savegame_present() -> bool:
	var f = File.new()
	return f.file_exists(SAVEFILE_PATH)

func clear_gamestate():
	if is_savegame_present():
		var dir = Directory.new()
		dir.remove(SAVEFILE_PATH)
	
func load_gamestate():
	_savefile = ConfigFile.new()
	if _savefile != null:
		_savefile.set_value("light_rune_found", light_rune_found)
		_savefile.set_value("player_hp", player_hp) 
		_savefile.get_value("weapon_level", weapon_level)
		_savefile.get_value("heal_level", heal_level)
		_savefile.get_value("player_position", player_position)
		_savefile.save(SAVEFILE_PATH)
			
	

# The map parser will provide the initial charachter position
func reset(initial_position : Vector2):
	light_rune_found = false
	player_hp = INITIAL_HP
	weapon_level = 0
	heal_level = 0
	
func collect_weapon():
	weapon_level += 1
	save_gamestate()
	
func collect_healing():
	heal_level += 1
	heal_level = clamp(heal_level, 0, len(healing_progression) - 1)
	player_hp = healing_progression[heal_level]
	save_gamestate()
	
func collect_light_rune():
	light_rune_found = true
	save_gamestate()
	
func set_position(pos : Vector2):
	player_position = pos
	save_gamestate()
	


