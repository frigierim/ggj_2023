extends MarginContainer

onready var nemico = get_node("%Nemico")
onready var alleato = get_node("%Alleato")

# Variabili
var canAttack:bool = true
var damage:float = 0
var turno:bool = false
var finished:bool = false
#true -> turno nemico
#false -> turno alleato

var choice = RandomNumberGenerator.new()
func _num():
	choice.randomize()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func attack(weapon):
	if (turno == false and canAttack == true):
		canAttack = false
		alleato.attack(turno)
		damage = GameStatus.getDamage(weapon, nemico.enemy_type)
		nemico.damage(damage)
		nemico.vita -= damage
		yield(get_tree().create_timer(3.0), "timeout")
		turno = true
		
# Headbutt Attack
func _on_Headbutt_pressed():
	attack("headbutt")
		
# Hatchet Attack
func _on_Hatchet_pressed():
	attack("hatchet")
		
# Two-Headed Axe Attack
func _on_2H_Axe_pressed():
	attack("two_headed axe")
		
# Sword Attack
func _on_Sword_pressed():
	attack("sword")
		
# Hammer attack
func _on_Hammer_pressed():
	attack("hammer")
		
# Spear Attack
func _on_Spear_pressed():
	attack("spear")
	
func backToMap():
	if(finished == false):
		Game.change_scene("res://scenes/tilemap/TileMapScene.tscn")
		finished = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (alleato.vita > 0 and nemico.vita > 0):
			if(turno == true):
				nemico.attack(turno)
				alleato.damage(10)
				alleato.vita -= 10
				turno = false
				canAttack = true
				
	if(nemico.vita <= 0):
		canAttack = false
		nemico.dead()
		yield(get_tree().create_timer(4), "timeout")
		backToMap()
