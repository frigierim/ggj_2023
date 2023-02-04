extends Sprite

# Statistiche
var vita:int = 100


func combat(string):
	print(string)

# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.max_value = vita
	$ProgressBar.value = vita

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ProgressBar.value = vita

