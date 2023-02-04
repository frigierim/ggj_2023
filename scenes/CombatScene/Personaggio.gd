extends Control

onready var bar = get_node("%Bar")
onready var hp = get_node("%hp")
onready var hit = get_node("%Hit Popup")

# Statistiche
export var enemy_type:String = "Alleato"
export var vita:int = 120
var maxVita:int = vita

var velocita:Vector2
var VELK:float = 50.0
var isAttacking:bool = false
var isDead:bool = false
var isDamage:bool = false
var opacity:float = 1
var turno:bool = false
#true -> nemico
#false -> alleato

func attack(turn):
	isAttacking = true
	self.turno = turn
	
func damage(damage:int):
	hit.text = String(-(damage + 1))
	isDamage = true
	
func dead():
	isDead = true
	
func set_velocita():
	if(turno != true):
		velocita = Vector2(VELK, 0)
	else:
		velocita = Vector2(-VELK, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	bar.max_value = maxVita
	bar.min_value = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bar.value = vita
	hp.text = String(vita) + "/" + String(maxVita)
	
	if(isAttacking == true):
		isAttacking = false
		set_velocita()
		for _i in range(1, 100):
			self.rect_position += velocita * delta
		yield(get_tree().create_timer(0.2), "timeout")
		turno = !turno
		set_velocita()
		for _i in range(1, 100):
			self.rect_position += velocita * delta
			
	if(isDamage == true):
		isDamage = false
		VELK = 100
		velocita = Vector2(0, -VELK)
		for i in range(1, 100):
			hit.rect_position += velocita * delta
			yield(get_tree().create_timer(0.005), "timeout")
		yield(get_tree().create_timer(0.5), "timeout")
		hit.visible = false
		
		velocita = Vector2(0, VELK)
		for i in range(1, 100):
			hit.rect_position += velocita*delta
		hit.visible = true
		VELK = 50.0
		
		
	if(isDead == true):
		isDead = false
		opacity = 1
		hit.visible = false
		while(opacity >= 0.1):
			self.modulate.a = opacity
			yield(get_tree().create_timer(0.01), "timeout")
			opacity -= 0.01
		self.visible = false
