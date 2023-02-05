extends Node2D
onready var map_camera = $"%MapCamera"
onready var game_map = $"%GameMap"
onready var player = $"%Player"
onready var fog = $"%Fog"
onready var visible_map = $"%VisibleMap"
onready var scripts_map = $"%ScriptsMap"
onready var combat_layer = $"%CombatLayer"
onready var combat_scene = $"%CombatScene"

const MAP_H = 21
const MAP_W = 21

const MAP_MIN_X = 0
const MAP_MAX_X = 50
const MAP_MIN_Y = 0
const MAP_MAX_Y = 64

const TILE_H : int = 16
const TILE_W : int = 16

const TILE_ID_PATH : int = 20

# Completely black tile, to be used on the Visible Map
const TILE_ID_HIDDEN : int = 0

# Half hidden node
const TILE_ID_HALFVIS : int = 23

# No tile, to be uset to reveal elements in the Visible Map
const TILE_ID_EMPTY : int = -1

var position_x : int = 0
var position_y : int = 0

var _target_x : int = -1
var _target_y : int = -1
var _moving : bool = false
var _accept_input : bool = false
var first_blood : bool = false

export var illumination : bool = false setget _set_illumination
export var spawn_pct : float = 0.01

enum MovementDirection { NORTH, EAST, SOUTH, WEST }

func _ready():
	# Resize camera
	map_camera.limit_top = 0
	map_camera.limit_left = 0
	map_camera.limit_bottom = MAP_H * TILE_H
	map_camera.limit_right  = MAP_W * TILE_W
	fog.scale = Vector2(Game.size.x / 10.0, Game.size.y / 10.0)
	_accept_input = false
	
	fog.visible = true
	first_blood = false
	
	# The game map is used only as a reference, but we show the underlying image
	game_map.visible = false
	scripts_map.visible = false
	parse_map()
	_handle_new_position(position_x, position_y)


	if GameStatus.first_combat == true:
		GameStatus.set_running_first_combat(false)
		# Play first battle dialog
		_accept_input = false
		print("First battle, disabling input")
		var FirstBattle = Dialogic.start('FirstBattle')
		add_child(FirstBattle)
		FirstBattle.connect("dialogic_signal", self, "_dialogic_end")
		first_blood = true


func _set_illumination(new_value : bool):
	if visible_map:
		if new_value:
			visible_map.self_modulate = Color(1,1,1, .98)
			fog.visible = false
		else:
			visible_map.self_modulate = Color(1,1,1, 0)
			fog.visible = true
	
	illumination = new_value
	
func parse_map():
	# Find points of interest on the map

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
						
	if GameStatus.player_position == Vector2(-1,-1):
		player.position = Vector2(position_x * TILE_W, position_y * TILE_H)
	else:
		position_x = GameStatus.player_position.x as int
		position_y = GameStatus.player_position.y as int
		
		player.position = GameStatus.player_position * Vector2(TILE_W, TILE_H)
	
	print("Entering map, position %d - %d" % [position_x, position_y ])				
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
	
	if not illumination:
		_fill_tile(position_x, position_y, TILE_ID_HIDDEN)
	else:
		_fill_tile(position_x, position_y, TILE_ID_HALFVIS)
		
	position_x = _target_x
	position_y = _target_y
	_fill_tile(_target_x, _target_y, TILE_ID_EMPTY)
	print("Movement finished")
	_handle_new_position(position_x, position_y)
	
func _move(direction : int):
	
	
	match direction:
		
		MovementDirection.NORTH:
			if _check_position(position_x, position_y - 1):
				_accept_input = false
				print("Movement accepted,  disabling input")
				_translate(position_x, position_y - 1, direction)
					
		MovementDirection.EAST:
			if _check_position(position_x + 1, position_y):
				_accept_input = false
				print("Movement accepted,  disabling input")
				_translate(position_x + 1, position_y, direction)
			
		MovementDirection.SOUTH:
			if _check_position(position_x, position_y + 1):
				_accept_input = false
				print("Movement accepted,  disabling input")
				_translate(position_x, position_y + 1, direction)
			
		MovementDirection.WEST:
			if _check_position(position_x - 1, position_y):
				_accept_input = false
				print("Movement accepted,  disabling input")
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
	print("Dialogue complete, reaccepting inputs")
	_accept_input = true
	
func _handle_new_position(x: int, y: int):
	
	GameStatus.set_position(Vector2(x,y))
	print("Setting position %d, %d" % [x, y])
	
	# Check for scripted encounters
	var cell_id = scripts_map.get_cell(x, y)
	if cell_id != -1:
		
		if GameStatus.is_event_collected(Vector2(x,y)):
			# we've already been here
			_accept_input = true
			return

		GameStatus.collect_event(Vector2(x,y))
		
		var tile = scripts_map.tile_set.tile_get_name(cell_id)
		print(tile)
		match tile:
				
			"start":
				
				#var StartScene = Dialogic.start('StartingScene')
				#add_child(StartScene)
				#StartScene.connect("dialogic_signal", self, "_dialogic_end")
				_accept_input = true

			"end":
				print("Game over!")
				var EndingScene = Dialogic.start('EndingScene')
				add_child(EndingScene)
				EndingScene.connect("dialogic_signal", self, "_dialogic_end")
				
				
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
					print("Dead end found!")
					var DeadEndScene = Dialogic.start(dead_ends[Vector2(x,y)])
					add_child(DeadEndScene)
					DeadEndScene.connect("dialogic_signal", self, "_dialogic_end")
				else:
					print("Dead end not found")
					assert(false)
					_accept_input = true

				
			"health":
				GameStatus.collect_healing()
				var HealScene = Dialogic.start('HealScene')
				add_child(HealScene)
				HealScene.connect("dialogic_signal", self, "_dialogic_end")
				
			"weapon":
				GameStatus.collect_weapon()
				var WeaponScene = Dialogic.start('WeaponScene')
				add_child(WeaponScene)
				WeaponScene.connect("dialogic_signal", self, "_dialogic_end")
				
			"first_enemy":
				start_combat("snakes")
				GameStatus.set_running_first_combat(true)
							
			"light_rune":
				GameStatus.collect_light_rune()
				var FirstEvent = Dialogic.start('FirstEvent')
				add_child(FirstEvent)
				self.illumination = true
				FirstEvent.connect("dialogic_signal", self, "_dialogic_end")
				
			"pre_boss":
				var BBWarning = Dialogic.start('BBWarning')
				add_child(BBWarning)
				BBWarning.connect("dialogic_signal", self, "_dialogic_end")
				
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
			print("No encounter, reaccepting inputs")
			_accept_input = true
			

func start_combat(enemy : String):
	var params = {
		"enemy" : enemy
	}

	combat_scene.visible = true
	combat_scene.pre_start(params)
	$AnimationPlayer.play("combat_fade_in")


func _on_CombatScene_encounter_end():
	$AnimationPlayer.play("combat_fade_out")
	
func _combat_scene_closed():
	combat_scene.visible = false
	_accept_input = true
	print("Combat complete, reaccepting inputs")
	# TODO: game over?
