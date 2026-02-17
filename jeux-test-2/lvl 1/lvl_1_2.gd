extends Node2D

@onready var player = $Player
@onready var spawn_point = $SpawnPoint

# progress bar 
@onready var ui = $ui

@export var level_start_x = -500
@export var level_end_x = 1321 # mets la position X de ton drapeau de fin



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

	#progress bar
	ui.setup_progress(player, level_start_x, level_end_x)	
	

func _on_drapeau_fin_level_completed() -> void:
	#get_tree().change_scene_to_file("res://Menu/menu_principal.tscn")
	$"Lvl 1_1 music".stop()
