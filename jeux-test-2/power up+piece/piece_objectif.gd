extends Area2D

# --- PARAMÈTRES EXPORTÉS ---
@export var level_id: String = "Lvl_1_1" # Identifiant du niveau auquel appartient cette pièce objectif
@export var piece_objectif_id: String = "piece_objectif_1"   # Identifiant unique de cette pièce dans le niveau (ex: "piece_objectif_1")

# --- RÉFÉRENCES ---
@onready var collision := $CollisionShape2D # Référence à la forme de collision de la pièce
@onready var collect := $AudioStreamPlayer # Référence au lecteur audio pour le son de collecte
@onready var sprite := $AnimatedSprite2D # Référence au sprite animé de la pièce

# --- SIGNAUX ---
signal collected # Signal émis quand la pièce est ramassée par le joueur

# --- VARIABLES DE SAUVEGARDE ---
var save_path = "user://savegame.json" # Chemin vers le fichier de sauvegarde
var data: Dictionary = {}   # Dictionnaire principal de données de sauvegarde
var piece_objectif := {} # Dictionnaire des états des pièces objectif
var levels_data := {} # Dictionnaire des données de niveaux


# --- INITIALISATION ---
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_state_from_save() # Applique l'état sauvegardé dès le chargement de la scène


# --- APPLICATION DE L'ÉTAT DEPUIS LA SAUVEGARDE ---
func _apply_state_from_save() -> void:
	var raw = Global.data.get("piece_objectif", {}).get(level_id, {}).get(piece_objectif_id, "MISSING") # Récupère la valeur brute depuis les données globales pour debug
	print("RAW=", raw, " TYPE=", typeof(raw)) # Affiche la valeur brute et son type pour debug
	var done := Global.is_piece_objectif_collected(level_id, piece_objectif_id) # Vérifie via Global si la pièce a déjà été collectée dans une session précédente
	visible = true  # Garantit que la pièce ne soit pas "disparue" visuellement au chargement
	if done: # Si la pièce a déjà été collectée dans une session précédente
		# Déjà récupérée -> anim + plus de collision
		sprite.play("piece recup") # Joue l'animation de pièce déjà récupérée
		collision.set_deferred("disabled", true) # Désactive la collision en différé (thread-safe)
		set_deferred("monitoring", false) # Désactive la détection d'entrée en différé
		set_deferred("monitorable", false) # Rend la zone non détectable par d'autres en différé
		print("deja recup") # Message de debug : pièce déjà récupérée
	else:
		# Pas récupérée -> elle DOIT être là
		sprite.play("default")  # Joue l'animation normale de la pièce disponible
		collision.set_deferred("disabled", false) # Active la collision en différé
		set_deferred("monitoring", true) # Active la détection d'entrée en différé
		set_deferred("monitorable", true) # Rend la zone détectable par d'autres en différé
		print("pas recup") # Message de debug : pièce pas encore récupérée


# --- COLLECTE DE LA PIÈCE PAR LE JOUEUR ---
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): # Vérifie que le corps entré appartient bien au groupe "Player"
		return # Ignore les collisions avec tout ce qui n'est pas le joueur

	if Global.is_piece_objectif_collected(level_id, piece_objectif_id): # Vérifie que la pièce n'a pas déjà été collectée
		return # Ne fait rien si la pièce est déjà marquée comme collectée

	# sauvegarde
	Global.set_piece_objectif_collected(level_id, piece_objectif_id) # Enregistre la collecte de la pièce dans les données globales (sauvegarde)
	emit_signal("collected") # Émet le signal pour informer le niveau que la pièce a été collectée

	# feedback + désactivation
	if collect: collect.play() # Lance le son de collecte si le lecteur audio existe
	if sprite: sprite.play("piece recup") # Joue l'animation de pièce récupérée si le sprite existe
	if collision: collision.set_deferred("disabled", true) # Désactive la collision en différé pour éviter les doubles déclenchements
	set_deferred("monitoring", false) # Désactive la détection d'entrée en différé
	set_deferred("monitorable", false) # Rend la zone non détectable par d'autres en différé
