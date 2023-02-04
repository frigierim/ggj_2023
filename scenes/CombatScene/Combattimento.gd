extends MarginContainer

onready var attack1 = get_node("%attack1")
onready var attack2 = get_node("%attack2")
onready var attack3 = get_node("%attack3")
onready var nemico = get_node("%Nemico")
onready var alleato = get_node("%Alleato")

# Variabili
var canAttack:bool = true
var turno:bool = false
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
		nemico.vita -= GameStatus.getDamage(weapon, nemico.enemy_type)
		yield(get_tree().create_timer(2.0), "timeout")
		turno = true
		
# Headbutt Attack
func _on_Headbutt_pressed():
	attack("Headbutt")
		
# Hatchet Attack
func _on_Hatchet_pressed():
	attack("Hatchet")
		
# Two-Headed Axe Attack
func _on_2H_Axe_pressed():
	attack("Two-Headed Axe")
		
# Sword Attack
func _on_Sword_pressed():
	attack("Sword")
		
# Hammer attack
func _on_Hammer_pressed():
	attack("Hammer")
		
# Spear Attack
func _on_Spear_pressed():
	attack("Spear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var numero_attacco:int = choice.randf_range(1, 3.9)
	if (alleato.vita > 0 and nemico.vita > 0):
		if(numero_attacco == 1):
			if(turno == true):
				nemico.attack(turno)
				alleato.vita -= 10
				turno = false
				canAttack = true
			
		if(numero_attacco == 2):
			if(turno == true):
				nemico.attack(turno)
				alleato.vita -= 5
				turno = false
				canAttack = true
			
		if(numero_attacco == 3):
			if(turno == true):
				nemico.attack(turno)
				alleato.vita -= 3
				turno = false
				canAttack = true
				
	if(nemico.vita <= 0):
		canAttack = false
		nemico.dead()
