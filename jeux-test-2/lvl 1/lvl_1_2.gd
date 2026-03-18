extends Node2D

# --- RÉFÉRENCES ---
@onready var player = $Player # Référence au nœud joueur dans la scène
@onready var spawn_point = $SpawnPoint # Référence au point de spawn de départ du joueur

# progress bar
@onready var ui = $ui # Référence au nœud UI (interface HUD) de la scène

# --- PARAMÈTRES EXPORTÉS ---
@export var level_start_x = -500 # Position X du début du niveau (pour la barre de progression)
@export var level_end_x = 1321 # Position X de la fin du niveau (là où se trouve le drapeau)


# --- CHARGEMENT DU CHECKPOINT AVANT L'ENTRÉE DANS L'ARBRE ---
func _enter_tree():
	Global.load_checkpoint() # Charge le checkpoint sauvegardé depuis le fichier JSON

	var player = get_node("Player") # Récupère le nœud joueur (variable locale pour le spawn)
	var spawn_point = get_node("SpawnPoint") # Récupère le nœud spawn point (variable locale pour le spawn)

	if Global.checkpoint_position != Vector2.ZERO: # Vérifie si un checkpoint a été sauvegardé (position non nulle)
		player.global_position = Global.checkpoint_position # Téléporte le joueur à la position du checkpoint
		#print("Spawn au checkpoint")
	else:
		player.global_position = spawn_point.global_position # Téléporte le joueur au point de spawn initial
		#print("Spawn au début")


# --- INITIALISATION ---
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#progress bar
	ui.setup_progress(player, level_start_x, level_end_x) # Configure la barre de progression avec le joueur et les limites du niveau


# --- CALLBACK : FIN DE NIVEAU (signal du drapeau) ---
func _on_drapeau_fin_level_completed() -> void:
	#get_tree().change_scene_to_file("res://Menu/menu_principal.tscn") # (désactivé) Retour au menu principal
	$"Lvl 1_1 music".stop() # Arrête la musique du niveau quand le drapeau de fin est atteint
