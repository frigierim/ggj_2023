extends Node2D

# Variabili
var turno:bool = false

var choice = RandomNumberGenerator.new()
func _num():
	choice.randomize()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

#DA SISTEMARE:
#Posso colpire tante volte in sequenza
#Invece dovrei colpire e poi non potere più finchè non attacca il nemico

func show_than_hide_box_attack1():
	$Alleato/sword/attack1.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$Alleato/sword/attack1.visible = false

func show_than_hide_box_attack2():
	$Alleato/fist/attack2.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$Alleato/fist/attack2.visible = false
	
func show_than_hide_box_attack3():
	$Alleato/warhead/attack3.visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	$Alleato/warhead/attack3.visible = false

func _on_sword_pressed() -> void:
	if (turno == false):
		$Alleato.combat("Alleato con spada")
		$Nemico.vita -= 25
		show_than_hide_box_attack1()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true

func _on_fist_pressed() -> void:
	if (turno == false):
		$Alleato.combat("Alleato con pugno")
		$Nemico.vita -= 10
		show_than_hide_box_attack2()
		yield(get_tree().create_timer(4.0), "timeout")
		turno = true
		
func _on_warhead_pressed() -> void:
	if (turno == false):
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
			
		if(numero_attacco == 2):
			if(turno == true):
				$Nemico.combat("Nemico con 2")
				$Alleato.vita -= 5
				turno = false
			
		if(numero_attacco == 3):
			if(turno == true):
				$Nemico.combat("Nemico con 3")
				$Alleato.vita -= 3
				turno = false
