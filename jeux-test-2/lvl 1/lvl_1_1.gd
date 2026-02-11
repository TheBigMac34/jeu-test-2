extends Node2D

@onready var player = $Player
@onready var spawn_point = $SpawnPoint

func _enter_tree():
	Global.load_checkpoint()

	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoint")

	if Global.checkpoint_position != Vector2.ZERO:
		player.global_position = Global.checkpoint_position
		#print("Spawn au checkpoint")
	else:
		player.global_position = spawn_point.global_position
		#print("Spawn au début")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Lvl 1_1 music".play()
	
	
	

func _on_drapeau_fin_level_completed() -> void:
	#get_tree().change_scene_to_file("res://Menu/menu_principal.tscn")
	$"Lvl 1_1 music".stop()
