extends Node2D
onready var map_camera = $"%MapCamera"
onready var game_map = $"%GameMap"
onready var player = $"%Player"
onready var fog = $"%Fog"
onready var visible_map = $"%VisibleMap"
onready var scripts_map = $"%ScriptsMap"

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

# No tile, to be uset to reveal elements in the Visible Map
const TILE_ID_EMPTY : int = -1

var position_x : int = 0
var position_y : int = 0

var _target_x : int = -1
var _target_y : int = -1
var _moving : bool = false

export var illumination : bool = false setget _set_illumination
export var spawn_pct : float = 0.1

enum MovementDirection { NORTH, EAST, SOUTH, WEST }

func _ready():
	# Resize camera
	map_camera.limit_top = 0
	map_camera.limit_left = 0
	map_camera.limit_bottom = MAP_H * TILE_H
	map_camera.limit_right  = MAP_W * TILE_W
	fog.scale = Vector2(Game.size.x / 10.0, Game.size.y / 10.0)
	
	var ratio = min(Game.size.x / MAP_W, Game.size.y / MAP_H)
	fog.material.set_shader_param("ratio", ratio)
	
	#fog.visible = true
	
	# The game map is used only as a reference, but we show the underlying image
	game_map.visible = false
	
	_moving = false
	parse_map()


func _set_illumination(new_value : bool):
	if visible_map:
		if new_value:
			visible_map.self_modulate = Color(1,1,1, .98)
		else:
			visible_map.self_modulate = Color(1,1,1, 0)
	
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
							player.position = GameStatus.player_position
							
						
						
	_update_fog_position(player.position)
	_fill_tile(position_x, position_y, TILE_ID_EMPTY)
	

func _check_position(x : int, y : int) -> bool:
	if x >= MAP_MIN_X and x <= MAP_MAX_X:
		if y >= MAP_MIN_Y and y <= MAP_MAX_Y:
			var map_id = game_map.get_cell(x, y)
			return map_id == TILE_ID_PATH
	
	return false		
	
	
func _update_fog_position(pos : Vector2):
	var uv = Vector2((pos.x - map_camera.position.x + TILE_W / 2.0) / Game.size.x, (pos.y - map_camera.position.y + TILE_H / 2.0) / Game.size.y)
	fog.material.set_shader_param("center_x", uv.x)
	fog.material.set_shader_param("center_y", uv.y)
	

func _fill_tile(x : int, y : int, cell_id : int):

	for j in range(clamp(y - 1, 0, MAP_MAX_Y), clamp(y + 1, 0, MAP_MAX_Y) + 1):
		for i in range(clamp(x - 1, 0, MAP_MAX_X), clamp(x + 1, 0, MAP_MAX_X) + 1):
			visible_map.set_cell(i, j, cell_id)

	
func _translate(x : int, y : int):
	
	_target_x = x
	_target_y = y
	
	if _target_x != position_x or _target_y != position_y:
		_moving = true
		var tweener = get_tree().create_tween().set_parallel()
		tweener.connect("finished", self, "_on_movement_finished")
		tweener.tween_property(player, "position", Vector2(_target_x * TILE_W, _target_y * TILE_H), 0.3)
		tweener.tween_method(self, "_update_fog_position", player.position, Vector2(_target_x * TILE_W, _target_y * TILE_H), 0.3)
		# Make the destination tile visible
		_fill_tile(_target_x, _target_y, TILE_ID_EMPTY)
	
func _on_movement_finished():
	
	if not illumination:
		_fill_tile(position_x, position_y, TILE_ID_HIDDEN)
	else:
		_fill_tile(position_x, position_y, TILE_ID_EMPTY)
		
	position_x = _target_x
	position_y = _target_y
	_fill_tile(_target_x, _target_y, TILE_ID_EMPTY)
	
	_handle_new_position(position_x, position_y)
		
	_moving = false
	

func _move(direction : int):
	
	if _moving:
		return false
	
	match direction:
		
		MovementDirection.NORTH:
			if _check_position(position_x, position_y - 1):
				_translate(position_x, position_y - 1)
					
		MovementDirection.EAST:
			if _check_position(position_x + 1, position_y):
				_translate(position_x + 1, position_y)
			
		MovementDirection.SOUTH:
			if _check_position(position_x, position_y + 1):
				_translate(position_x, position_y + 1)
			
		MovementDirection.WEST:
			if _check_position(position_x - 1, position_y):
				_translate(position_x - 1, position_y)
				

func _input(event):
	
	if event.is_action_pressed("ui_up"):
		_move(MovementDirection.NORTH)
		
	if event.is_action_pressed("ui_down"):
		_move(MovementDirection.SOUTH)
		
	if event.is_action_pressed("ui_left"):
		_move(MovementDirection.WEST)
		
	if event.is_action_pressed("ui_right"):
		_move(MovementDirection.EAST)


func _handle_new_position(x: int, y: int):
	
	# Check for scripted encounters
	var cell_id = scripts_map.get_cell(x, y)
	if cell_id != -1:
		
		if GameStatus.is_event_collected(Vector2(x,y)):
			# we've already been here
			return

		var tile = scripts_map.tile_set.tile_get_name(cell_id)
		match tile:
				
			"start":
				#TODO: Show dialog
				pass
				
			"end":
				#TODO: Show dialog
				print("Game over!")
				
			"health":
				GameStatus.collect_healing()
				#TODO: Show dialog
				
			"weapon":
				GameStatus.collect_weapon()
				#TODO: Show dialog
				
			"first_enemy":
				#TODO: Show dialog
				pass
			
			"light_rune":
				#TODO: show dialog
				GameStatus.collect_light_rune()
				illumination = true
				
			"pre_boss":
				#TODO: show dialog
				pass
				
			"boss":
				#TODO: show dialog
				#TODO: enter boss battle
				pass
				
			"neutral_end":
				pass
				
			_:
				assert(false)
				
		GameStatus.collect_event(Vector2(x,y))

	else:
		# No specific script found, verify encounter
		if randf() < spawn_pct:
			# Random encounter: set up enemies and trigger battle scene
			print("Fighting enemies")
			Game.change_scene("res://scenes/CombatScene/CombatScene.tscn")
