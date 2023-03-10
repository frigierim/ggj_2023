extends Node2D
onready var map_camera = $"%MapCamera"
onready var game_map = $"%GameMap"
onready var player = $"%Player"
onready var fog = $"%Fog"
onready var initial_fog = $"%InitialFog"
onready var visible_map = $"%VisibleMap"
onready var scripts_map = $"%ScriptsMap"
onready var combat_layer = $"%CombatLayer"
onready var combat_scene = $"%CombatScene"
onready var ui_layer = $"%UILayer"
onready var game_over_img = $"%GameOverImg"
onready var final_screen = $"%FinalScreen"
onready var collectible_layer = $"%CollectibleLayer"

const MAP_H = 50
const MAP_W = 64

const MAP_MIN_X = 0
const MAP_MAX_X = 50
const MAP_MIN_Y = 0
const MAP_MAX_Y = 64

const TILE_H : int = 16
const TILE_W : int = 16

const TILE_ID_PATH : int = 20

# Completely black tile, to be used on the Visible Map
const TILE_ID_HIDDEN : int = 0

# 50% visible tile for visited tiles
const TILE_ID_HALF : int = 23

# No tile, to be uset to reveal elements in the Visible Map
const TILE_ID_EMPTY : int = -1

var position_x : int = 0
var position_y : int = 0

var _target_x : int = -1
var _target_y : int = -1
var _moving : bool = false
var _accept_input : bool = false
var first_blood : bool = false
var game_over : bool = false

export var illumination : bool = false setget _set_illumination
export var spawn_pct : float = 0.01

enum MovementDirection { NORTH, EAST, SOUTH, WEST }

var game_over_images = [
	preload("res://documentazione/Esempi BG/gameoverimage.jpg"), # Lose
	preload("res://documentazione/Esempi BG/youwin.png"), # Win
]

var collectible_scenes = {
	"health" : preload("res://scenes/potion/potion.tscn"),
	"weapon" : preload("res://scenes/weapon/weapon.tscn")
}

var collectibles : Dictionary = {}

func _ready():
	GameStatus.reset()
	# Resize camera
	map_camera.limit_top = 0
	map_camera.limit_left = 0
	#map_camera.limit_bottom = MAP_H * TILE_H
	#map_camera.limit_right  = MAP_W * TILE_W
	_accept_input = false
	
	initial_fog.visible = true
	fog.visible = false
	first_blood = false
	game_over = false
	
	ui_layer.connect("quit_pressed", self, "_on_quit_pressed")
	
	# The game map is used only as a reference, but we show the underlying image
	game_map.visible = false
	scripts_map.visible = false
	final_screen.visible = false
	
	parse_map()
	_handle_new_position(position_x, position_y)

func _set_illumination(new_value : bool):
	if visible_map:
		if new_value:
			visible_map.self_modulate = Color(1,1,1, .98)
			fog.visible = true
			initial_fog.visible = false
		else:
			visible_map.self_modulate = Color(1,1,1, 0)
			fog.visible = false
			initial_fog.visible = true
	
	illumination = new_value
	
func parse_map():
	# Find points of interest on the map
	for c in collectible_layer.get_children():
		c.queue_free()

	for j in range(MAP_MAX_Y):
		for i in range(MAP_MAX_X):
			
			# use the visible map to cover areas not yet met before the light rune
			visible_map.set_cell(i, j, TILE_ID_HIDDEN)
			
			var cell_id = scripts_map.get_cell(i, j)
			if cell_id != -1:
				
				var tile = scripts_map.tile_set.tile_get_name(cell_id)
				match tile:
					"start":
						
						position_x = i
						position_y = j
				
				
					"health":
						if not GameStatus.is_event_collected(Vector2(i,j)):
							var health_icon = collectible_scenes[tile].instance()
							health_icon.position = Vector2(i * TILE_W, j * TILE_H)
							collectibles[Vector2(i,j)] = health_icon
							collectible_layer.add_child(health_icon)
							
					"weapon":
						if not GameStatus.is_event_collected(Vector2(i,j)):
							var weapon_icon = collectible_scenes[tile].instance()
							weapon_icon.position = Vector2(i * TILE_W, j * TILE_H)
							collectibles[Vector2(i,j)] = weapon_icon
							collectible_layer.add_child(weapon_icon)
						
	if GameStatus.player_position == Vector2(-1,-1):
		player.position = Vector2(position_x * TILE_W, position_y * TILE_H)
	else:
		position_x = GameStatus.player_position.x as int
		position_y = GameStatus.player_position.y as int
		player.position = GameStatus.player_position * Vector2(TILE_W, TILE_H)
	
	_fill_tile(position_x, position_y, TILE_ID_EMPTY)
	

func _check_position(x : int, y : int) -> bool:
	if x >= MAP_MIN_X and x <= MAP_MAX_X:
		if y >= MAP_MIN_Y and y <= MAP_MAX_Y:
			var map_id = game_map.get_cell(x, y)
			return map_id == TILE_ID_PATH
	
	return false		
	
		
		

func _fill_tile(x : int, y : int, cell_id : int):

	for j in range(clamp(y - 1, 0, MAP_MAX_Y), clamp(y + 1, 0, MAP_MAX_Y) + 1):
		for i in range(clamp(x - 1, 0, MAP_MAX_X), clamp(x + 1, 0, MAP_MAX_X) + 1):
			visible_map.set_cell(i, j, cell_id)

	
func _translate(x : int, y : int, Direction:int):
	
	_target_x = x
	_target_y = y
	var animations = {MovementDirection.NORTH:"Up", MovementDirection.SOUTH:"Down", MovementDirection.EAST:"Right", MovementDirection.WEST:"Left"}
	
	
	if _target_x != position_x or _target_y != position_y:
		_moving = true
		player.play(animations[Direction])
		var tweener = get_tree().create_tween().set_parallel()
		tweener.connect("finished", self, "_on_movement_finished")
		tweener.tween_property(player, "position", Vector2(_target_x * TILE_W, _target_y * TILE_H), 0.3)
		# Make the destination tile visible
		_fill_tile(_target_x, _target_y, TILE_ID_EMPTY)
	
func _on_movement_finished():
	
	player.stop()
	player.frame = 0
	
	if not illumination:
		_fill_tile(position_x, position_y, TILE_ID_HIDDEN)
	else:
		_fill_tile(position_x, position_y, TILE_ID_EMPTY)
		
	position_x = _target_x
	position_y = _target_y
	_fill_tile(_target_x, _target_y, TILE_ID_EMPTY)
	_handle_new_position(position_x, position_y)
	
func _move(direction : int):
	
	
	match direction:
		
		MovementDirection.NORTH:
			if _check_position(position_x, position_y - 1):
				_accept_input = false
				_translate(position_x, position_y - 1, direction)
					
		MovementDirection.EAST:
			if _check_position(position_x + 1, position_y):
				_accept_input = false
				_translate(position_x + 1, position_y, direction)
			
		MovementDirection.SOUTH:
			if _check_position(position_x, position_y + 1):
				_accept_input = false
				_translate(position_x, position_y + 1, direction)
			
		MovementDirection.WEST:
			if _check_position(position_x - 1, position_y):
				_accept_input = false
				_translate(position_x - 1, position_y, direction)
				

func _input(event):
	
	if not _accept_input:
		return
		
	if event.is_action_released("ui_up"):
		_move(MovementDirection.NORTH)
		
	if event.is_action_released("ui_down"):
		_move(MovementDirection.SOUTH)
		
	if event.is_action_released("ui_left"):
		_move(MovementDirection.WEST)
		
	if event.is_action_released("ui_right"):
		_move(MovementDirection.EAST)

func _dialogic_end(_arg):
	ui_layer.visible = true
	_accept_input = true
	
	if game_over == true:
		game_over_screen(true)

	
func _handle_new_position(x: int, y: int):
	
	GameStatus.set_position(Vector2(x,y))
	
	# Check for scripted encounters
	var cell_id = scripts_map.get_cell(x, y)
	if cell_id != -1:
		
		if GameStatus.is_event_collected(Vector2(x,y)):
			# we've already been here
			_accept_input = true
			return

		GameStatus.collect_event(Vector2(x,y))
		
		var tile = scripts_map.tile_set.tile_get_name(cell_id)
		match tile:
				
			"start":
				
				var StartScene = Dialogic.start('StartingScene')
				add_child(StartScene)
				StartScene.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				#_accept_input = true
				
			"end":
				game_over = true
				ui_layer.visible = false
				var EndingScene = Dialogic.start('EndingScene')
				add_child(EndingScene)
				EndingScene.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				
			"neutral_end":
				var dead_ends = {
					
					Vector2(15,51) : "D1",
					Vector2(37,9)  : "D2",
					Vector2(21,57) : "D3",
					Vector2(31,19) : "D4",
					Vector2(3,21) : "D5",
					Vector2(29,5) : "D6",
					Vector2(13,5) : "D7",
				}
				
				if dead_ends.has(Vector2(x,y)):
					var DeadEndScene = Dialogic.start(dead_ends[Vector2(x,y)])
					add_child(DeadEndScene)
					DeadEndScene.connect("dialogic_signal", self, "_dialogic_end")
					ui_layer.visible = false
				else:
					assert(false)
					_accept_input = true

				
			"health":
				GameStatus.collect_healing()
				collectible_layer.remove_child(collectibles[Vector2(x,y)])
				collectibles[Vector2(x,y)].queue_free()
				collectibles.erase(Vector2(x,y))
				
				var HealScene = Dialogic.start('HealScene')
				add_child(HealScene)
				HealScene.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				
			"weapon":
				GameStatus.collect_weapon()
				collectible_layer.remove_child(collectibles[Vector2(x,y)])
				collectibles[Vector2(x,y)].queue_free()
				collectibles.erase(Vector2(x,y))
				
				var WeaponScene = Dialogic.start('WeaponScene')
				add_child(WeaponScene)
				WeaponScene.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				
			"first_enemy":
				start_combat("snakes")
							
			"light_rune":
				GameStatus.collect_light_rune()
				var FirstEvent = Dialogic.start('FirstEvent')
				add_child(FirstEvent)
				self.illumination = true
				FirstEvent.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				
			"pre_boss":
				var BBWarning = Dialogic.start('BBWarning')
				add_child(BBWarning)
				BBWarning.connect("dialogic_signal", self, "_dialogic_end")
				ui_layer.visible = false
				
			"boss":
				var BossBattleScene = Dialogic.start('BossBattleScene')
				add_child(BossBattleScene)
				yield(BossBattleScene, "dialogic_signal")
				start_combat("nidhogg")
				
			_:
				assert(false)
	
	else:
		# No specific script found, verify encounter (not before first scripted fight
		if randf() < spawn_pct and first_blood:
			# Random encounter: set up enemies and trigger battle scene
			var enemy_chance = [ "snakes", "snakes", "snakes", "snakes", "snakes", 
								"ulfsarks", "ulfsarks", "ulfsarks", "jotunn", "jotunn"
								]

			start_combat(enemy_chance[randi() % len(enemy_chance)])
		else:
			_accept_input = true
			

func start_combat(enemy : String):
	var params = {
		"enemy" : enemy
	}

	ui_layer.visible = false
	combat_scene.visible = true
	combat_scene.pre_start(params)
	$AnimationPlayer.play("combat_fade_in")


func _on_CombatScene_encounter_end():
	$AnimationPlayer.play("combat_fade_out")
	
	if GameStatus.player_hp <= 0:
		game_over_screen(false)
		
	
func _combat_scene_closed():
	combat_scene.visible = false
	ui_layer.visible = true
	_accept_input = true
	
	if not first_blood and GameStatus.player_hp > 0:
		# Play first battle dialog
		_accept_input = false
		var FirstBattle = Dialogic.start('FirstBattle')
		add_child(FirstBattle)
		FirstBattle.connect("dialogic_signal", self, "_dialogic_end")
		first_blood = true
		
		
func game_over_screen(win : bool):
	
	_accept_input = false
	final_screen.visible = true	
	
	if win:
		game_over_img.texture = game_over_images[1]
	else:
		game_over_img.texture = game_over_images[0]
	
	yield(get_tree().create_timer(3.0)	,"timeout")
	Game.change_scene("res://scenes/menu/menu.tscn")
		

func _on_quit_pressed():
	Game.change_scene("res://scenes/menu/menu.tscn")
