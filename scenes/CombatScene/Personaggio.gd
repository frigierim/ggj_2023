extends Control

onready var bar = get_node("%Bar")

# Statistiche
export var vita:int = 100
var velocita:Vector2
var VELK:float = 50.0
var isAttacking:bool = false
var isDead:bool = false
var opacity:float = 1
var turno:bool = false
#true -> nemico
#false -> alleato

func attack(turno):
	isAttacking = true
	self.turno = turno
	
func dead():
	isDead = true
	
func set_velocita():
	if(turno != true):
		velocita = Vector2(VELK, 0)
	else:
		velocita = Vector2(-VELK,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bar.value = vita
	
	if(isAttacking == true):
		isAttacking = false
		set_velocita()
		for i in range(1, 100):
			self.rect_position += velocita * delta
		yield(get_tree().create_timer(0.2), "timeout")
		turno = !turno
		set_velocita()
		for i in range(1, 100):
			self.rect_position += velocita * delta
			
	if(isDead == true):
		isDead = false
		while(opacity > 0.1):
			self.modulate.a = opacity
			yield(get_tree().create_timer(0.4), "timeout")
			opacity -= 0.01
		self.modulate.a = 0
		


