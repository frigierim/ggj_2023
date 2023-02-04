extends Node2D

# Variabili
var turno:bool = false
#true -> turno nemico
#false -> turno alleato

var canAttack:bool = true

var choice = RandomNumberGenerator.new()
func _num():
	choice.randomize()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Mostra scritta attacco 1
func show_than_hide_box_attack1():
	$sword/attack1.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$sword/attack1.visible = false

# Mostra scritta attacco 2
func show_than_hide_box_attack2():
	$fist/attack2.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$fist/attack2.visible = false
	
# Mostra scritta attacco 3
func show_than_hide_box_attack3():
	$warhead/attack3.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$warhead/attack3.visible = false

# Attacco spada
func _on_sword_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		$Alleato.combat("Alleato con spada")
		$Nemico.vita -= 25
		show_than_hide_box_attack1()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true

# Attacco pugno
func _on_fist_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		$Alleato.combat("Alleato con pugno")
		$Nemico.vita -= 10
		show_than_hide_box_attack2()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true
		
# Attacco testata
func _on_warhead_pressed() -> void:
	if (turno == false and canAttack == true):
		canAttack = false
		$Alleato.combat("Alleato con testata")
		$Nemico.vita -= 15
		show_than_hide_box_attack3()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var numero_attacco:int = choice.randf_range(1, 3.9)
	if ($Alleato.vita > 0):
		if(numero_attacco == 1):
			if(turno == true):
				$Nemico.combat("Nemico con 1")
				$Alleato.vita -= 10
				turno = false
				canAttack = true
			
		if(numero_attacco == 2):
			if(turno == true):
				$Nemico.combat("Nemico con 2")
				$Alleato.vita -= 5
				turno = false
				canAttack = true
			
		if(numero_attacco == 3):
			if(turno == true):
				$Nemico.combat("Nemico con 3")
				$Alleato.vita -= 3
				turno = false
				canAttack = true
