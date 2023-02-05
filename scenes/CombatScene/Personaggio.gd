extends Control

onready var bar = get_node("%Bar")
onready var hp = get_node("%hp")
onready var hit = get_node("%Hit Popup")
onready var personaggio = get_node("%Personaggio")

var Images = {
	"snakes" : preload("res://assets/Combat Sprites/Snakes.png"),
	"ulfsarks" : preload("res://assets/Combat Sprites/Ulfsarks.png"),
	"jotunn" : preload("res://assets/Combat Sprites/Jotunn.png"),
	"nidhogg" : preload("res://documentazione/Characters/DurinnFaceBW.png"),
	
	# TODO: update player image
	"Alleato" : preload("res://assets/Combat Sprites/Jotunn.png")
}

# Statistiche
export var enemy_type:String = "Alleato" setget set_enemy_type
export var vita:int = 220
var maxVita:int = vita

var velocita:Vector2
var VELK:float = 50.0
var isAttacking:bool = false
var isDying:bool = false
var isDead:bool = false
var isDamage:bool = false
var opacity:float = 1
var turno:bool = false
#true -> nemico
#false -> alleato

func set_enemy_type(name:String):
	enemy_type = name
	if(Images.has(enemy_type)):
		personaggio.set_texture(Images[enemy_type])
		personaggio.set_flip_h(false)
		
		if enemy_type == "Alleato":
			vita = GameStatus.player_hp
			maxVita = GameStatus.player_max_hp
		else:
			#TODO: initialize enemy initial live
			maxVita = 220
			vita = 220
		
		bar.max_value = maxVita
		bar.min_value = 0
		
	else:
		assert(false)
	
	isAttacking = false
	isDying = false
	isDead = false
	isDamage = false
	opacity = 1
	turno = false
	self.visible = true
	self.modulate = Color(1,1,1,1)


func attack(turn):
	isAttacking = true
	self.turno = turn
	
func damage(damage:int):
	hit.text = String(-(damage + 1))
	isDamage = true
	
func dead():
	isDead = true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	bar.value = vita
	hp.text = String(vita) + "/" + String(maxVita)
	
	if(isAttacking == true):
		isAttacking = false
		var tweener = create_tween()
		var pos = self.rect_position
		if turno:
			tweener.tween_property(self, "rect_position", pos - Vector2(100,0), 0.3)
			tweener.tween_property(self, "rect_position", pos, 0.2)
		else:
			tweener.tween_property(self, "rect_position", pos + Vector2(100,0), 0.3)
			tweener.tween_property(self, "rect_position", pos, 0.2)
		turno = !turno
			
	if(isDamage == true):
		isDamage = false
		hit.visible = true
		var tweener = create_tween()
		var pos = hit.rect_position
		tweener.tween_property(hit, "rect_position", pos - Vector2(0, 100), 0.3)
		tweener.tween_property(hit, "rect_position", pos, 0.2)
		tweener.tween_property(hit, "visible", false, 0.0)

	if(isDead == true) and not isDying:
		isDying = true
		hit.visible = false
		$AnimationPlayer.play("fade_out")
