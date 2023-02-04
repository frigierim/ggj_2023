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

# Mostra scritta attacco 1
func show_than_hide_box_attack1():
	attack1.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	attack1.visible = false

# Mostra scritta attacco 2
func show_than_hide_box_attack2():
	attack2.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	attack2.visible = false
	
# Mostra scritta attacco 3
func show_than_hide_box_attack3():
	attack3.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	attack3.visible = false

# Attacco spada
func _on_sword_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		alleato.combat("Alleato con spada")
		nemico.vita -= 25
		show_than_hide_box_attack1()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true

# Attacco pugno
func _on_fist_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		alleato.combat("Alleato con pugno")
		nemico.vita -= 15
		show_than_hide_box_attack2()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true

# Attaccato testata
func _on_warhead_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		alleato.combat("Alleato con testata")
		nemico.vita -= 5
		show_than_hide_box_attack3()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var numero_attacco:int = choice.randf_range(1, 3.9)
	if (alleato.vita > 0):
		if(numero_attacco == 1):
			if(turno == true):
				nemico.combat("Nemico con 1")
				alleato.vita -= 10
				turno = false
				canAttack = true
			
		if(numero_attacco == 2):
			if(turno == true):
				nemico.combat("Nemico con 2")
				alleato.vita -= 5
				turno = false
				canAttack = true
			
		if(numero_attacco == 3):
			if(turno == true):
				nemico.combat("Nemico con 3")
				alleato.vita -= 3
				turno = false
				canAttack = true
