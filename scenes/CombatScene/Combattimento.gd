extends MarginContainer

onready var nemico = get_node("%Nemico")
onready var alleato = get_node("%Alleato")

# Variabili
var canAttack:bool = true
var damage:float = 0
var finished:bool = false
var turno:bool = false
#true -> turno nemico
#false -> turno alleato

signal encounter_end

func pre_start(params):
	nemico.enemy_type = params["enemy"]
	alleato.enemy_type = "Alleato"

	var weapon_nodes : Array = [
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/FirstCol/Headbutt, 
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/FirstCol/Hatchet, 
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/FirstCol/Axe,
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/SecondCol/Sword, 
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/SecondCol/Hammer, 
		$MainContainer/ContainerAlleato/Node2D/AttackContainer/SecondCol/Spear
	]

	for i in range(len(weapon_nodes)):
		if i <= GameStatus.weapon_level:
			weapon_nodes[i].visible = true
		else:
			weapon_nodes[i].visible = false

	canAttack = true
	damage = 0
	finished = false
	print("Entering combat, finished = false")
	turno = false

	Audio.play_music("res://assets/audio/battle.ogg")

func attack(weapon):
	if (turno == false and canAttack == true):
		canAttack = false
		alleato.attack(turno)
		damage = GameStatus.getDamage(weapon, nemico.enemy_type)
		nemico.damage(damage)
		nemico.vita -= damage
		if(nemico.vita <= 0):
			canAttack = false
			nemico.dead()
			get_tree().create_timer(3).connect("timeout", self, "_on_nemico_dead")
			return
		else:
			yield(get_tree().create_timer(2.0), "timeout")
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
		Audio.play_music("res://assets/audio/dungeon_ambient_1.ogg", false)
		print("Combattimento.gd: encounter_end")
		emit_signal("encounter_end")
		finished = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
		if (alleato.vita > 0 and nemico.vita > 0):
				if(turno == true):
					nemico.attack(turno)
					
					var damage = GameStatus.getEnemyDamage(nemico.enemy_type)
					alleato.damage(damage)
					alleato.vita -= damage
					GameStatus.player_damaged(damage)
					
					if GameStatus.player_hp <= 0:
						yield(get_tree().create_timer(2.0), "timeout")
						backToMap()
						
					turno = false
					canAttack = true
					
		
func _on_nemico_dead():
	backToMap()
