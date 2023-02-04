extends Control

# Statistiche
export var vita:int = 100

func combat(string):
	print(string)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Personaggio/ProgressBar.max_value = vita
	$Personaggio/ProgressBar.value = vita

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Personaggio/ProgressBar.value = vita

