extends Node2D

# --- RÉFÉRENCES ---
@onready var player_camera := get_viewport().get_camera_2d() # Récupère la caméra 2D active dans le viewport


# Appelé quand le nœud entre dans l'arbre de scène pour la première fois.
func _ready() -> void:
	pass # Remplacer par le corps de la fonction.


# --- LOGIQUE DE VISIBILITÉ ---
# Apparaît à la caméra : cache ou affiche le nœud selon s'il est dans la zone visible de la caméra
func _process(delta: float) -> void:
	if player_camera: # Vérifie que la caméra existe avant d'utiliser ses données
		var cam_pos = player_camera.global_position # Position globale actuelle de la caméra
		var screen_size = get_viewport_rect().size # Taille de l'écran (viewport) en pixels
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size) # Rectangle représentant la zone visible à l'écran (centrée sur la caméra)

		visible = visible_zone.has_point(global_position) # Rend le nœud visible seulement s'il est dans la zone caméra
		#print("visible")

# --- DÉGÂTS AU JOUEUR ---
func _on_balls_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré possède une méthode de prise de dégâts
		body.take_damage()  # Inflige des dégâts au corps touché (le joueur)
		print("touché par Balls") # Message de debug indiquant le contact avec Balls
