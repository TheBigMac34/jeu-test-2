extends PathFollow2D

# --- RÉFÉRENCES ---
@onready var player_camera := get_viewport().get_camera_2d() # Récupère la caméra 2D active dans le viewport

# --- PARAMÈTRES EXPORTÉS ---
@export var speed := 20 # Vitesse de déplacement de la chenille le long du chemin (PathFollow2D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# --- DÉPLACEMENT SUR LE CHEMIN ET VISIBILITÉ ---
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta # Avance la position sur le chemin selon la vitesse et le temps écoulé
	if player_camera: # Vérifie que la caméra existe avant d'utiliser ses données
		var cam_pos = player_camera.global_position # Position globale actuelle de la caméra
		var screen_size = get_viewport_rect().size # Taille de l'écran (viewport) en pixels
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size) # Rectangle représentant la zone visible centrée sur la caméra

		visible = visible_zone.has_point(global_position) # Rend le nœud visible seulement s'il est dans la zone caméra
		#print("vue")

# --- DÉGÂTS AU JOUEUR ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage()  # Inflige des dégâts au corps touché (le joueur)
		print("hit chenille") # Message de debug indiquant le contact avec la chenille
