extends Node2D

@onready var player = $Player
@onready var spawn_point = $SpawnPoint

# progress bar 
@onready var ui = $ui

@export var level_start_x = -500
@export var level_end_x = 2600 # mets la position X de ton drapeau de fin

#piece objectif
var level_id := "Lvl_1_1"
var objectif_count := 0
const MAX_OBJECTIF := 5
@onready var objectif_parent = $piece_objectif  


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
	#progress bar
	ui.setup_progress(player, level_start_x, level_end_x)
	#piece objectif
	# 1) Mettre l’UI à jour dès le début (si déjà des pièces sauvegardées)
	ui.update_piece_objectif_ui()
	# 2) Connecter les signaux "collected" de toutes les pièces
	for piece_objectif in objectif_parent.get_children():
		if piece_objectif.has_signal("collected"):
			piece_objectif.collected.connect(on_piece_objectif_collected)

func level_completed() -> void:
	$"Lvl 1_1 music".stop()
	print("fini")

func on_piece_objectif_collected():
	# si tu gardes un compteur pour afficher "x/5", ok :
	objectif_count = Global.get_piece_objectif_count(level_id)  # optionnel

	# ✅ met à jour les 5 slots selon piece_objectif_1..5
	$ui.update_piece_objectif_ui()
