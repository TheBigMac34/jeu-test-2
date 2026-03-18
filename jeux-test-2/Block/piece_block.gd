extends Node2D

# --- VARIABLES EXPORTÉES ---
@export var hauteur := 16 # Hauteur maximale (en pixels) de l'arc de montée de la pièce
@export var duree := 0.25 # Durée totale (en secondes) de l'animation de la pièce

# --- FONCTION D'ANIMATION ---
func start_animation():
	Global.coins += 1 # Incrémente le compteur de pièces global de 1
	set_as_top_level(true) # Détache la pièce de la hiérarchie pour que sa position soit indépendante du parent
	var start_pos = global_position # Mémorise la position de départ de la pièce
	var end_pos = global_position + Vector2(0, -hauteur) # Calcule la position haute (point culminant de l'arc)

	var tween = create_tween() # Crée un tween pour animer la position de la pièce
	tween.tween_property(self, "global_position", end_pos, duree / 2) # Anime la montée jusqu'au point culminant (moitié du temps)
	tween.tween_property(self, "global_position", start_pos, duree / 2) # Anime la descente jusqu'à la position de départ (moitié du temps)
	$AudioStreamPlayer.play() # Joue le son de collecte de la pièce
	await tween.finished # Attend que l'animation de montée/descente soit terminée
	visible = false # Cache la pièce visuellement une fois l'animation terminée

	await $AudioStreamPlayer.finished # Attend que le son de collecte soit complètement joué
	queue_free() # Supprime le nœud de la pièce de la scène
	#print("START:", global_position) # Debug désactivé : affichait la position de départ

# --- INITIALISATION ---
func _ready() -> void:
	pass # Aucune initialisation nécessaire au démarrage


# --- BOUCLE PRINCIPALE ---
func _process(delta: float) -> void:
	pass # Aucun traitement nécessaire chaque frame
