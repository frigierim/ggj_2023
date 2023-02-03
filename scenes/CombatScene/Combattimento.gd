extends Node2D

# Variabili
var turno:bool = false
var armi = [1, 2]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _input(event):
	if(event.is_action_pressed("combatti") && turno == false):
		$Alleato.combat("Alleato")
		$Nemico.vita -= 1
		turno = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(turno == true):
		$Nemico.combat("Nemico")
		$Alleato.vita -= 1
		turno = false
