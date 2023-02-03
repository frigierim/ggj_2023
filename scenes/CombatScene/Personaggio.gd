extends Sprite

# Statistiche
var vita:int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.max_value = vita
	$ProgressBar.value = vita

func combat(string):
	print(string)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ProgressBar.value = vita
