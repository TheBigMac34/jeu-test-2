extends Node2D

# --- RÉFÉRENCES ---
@onready var player = $Player # Référence au nœud joueur dans la scène
@onready var spawn_point = $SpawnPoint # Référence au point de spawn de départ du joueur

# progress bar
@onready var ui = $ui # Référence au nœud UI (interface HUD) de la scène

# --- PARAMÈTRES EXPORTÉS ---
@export var level_start_x = -500 # Position X du début du niveau (pour la barre de progression)
@export var level_end_x = 2600 # Position X de la fin du niveau (là où se trouve le drapeau)

# --- PIÈCES OBJECTIF ---
var level_id := "Lvl_1_1" # Identifiant du niveau pour la sauvegarde des pièces objectif
var objectif_count := 0 # Compteur local du nombre de pièces objectif collectées dans cette session
const MAX_OBJECTIF := 5 # Nombre total de pièces objectif dans ce niveau
@onready var objectif_parent = $piece_objectif  # Référence au nœud parent contenant toutes les pièces objectif


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
	$"Lvl 1_1 music".play() # Lance la musique du niveau 1-1
	#progress bar
	ui.setup_progress(player, level_start_x, level_end_x) # Configure la barre de progression avec le joueur et les limites du niveau
	#piece objectif
	# 1) Mettre l'UI à jour dès le début (si déjà des pièces sauvegardées)
	ui.update_piece_objectif_ui() # Met à jour l'affichage des pièces objectif dans le HUD dès le début
	# 2) Connecter les signaux "collected" de toutes les pièces
	for piece_objectif in objectif_parent.get_children(): # Parcourt tous les enfants du nœud parent des pièces objectif
		if piece_objectif.has_signal("collected"): # Vérifie que la pièce possède bien le signal "collected"
			piece_objectif.collected.connect(on_piece_objectif_collected) # Connecte le signal au callback local pour réagir à la collecte


# --- FIN DU NIVEAU ---
func level_completed() -> void:
	$"Lvl 1_1 music".stop() # Arrête la musique du niveau quand le niveau est terminé
	print("fini") # Message de debug indiquant que le niveau est terminé


# --- CALLBACK : PIÈCE OBJECTIF COLLECTÉE ---
func on_piece_objectif_collected():
	# si tu gardes un compteur pour afficher "x/5", ok :
	objectif_count = Global.get_piece_objectif_count(level_id)  # Met à jour le compteur local depuis les données globales (optionnel)

	# Met à jour les 5 slots selon piece_objectif_1..5
	$ui.update_piece_objectif_ui() # Rafraîchit l'affichage des slots de pièces objectif dans le HUD
