extends Node2D

# Variabili

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _input(event):
	if(event.is_action("combatti")):
		$Alleato.combat("Alleato")
		$Nemico.vita -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
