extends Area2D

# --- RÉFÉRENCES ---
@onready var player_camera := get_viewport().get_camera_2d() # Récupère la caméra 2D active dans le viewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# --- LOGIQUE DE VISIBILITÉ ---
# apparais a la camera
func _process(delta: float) -> void:
	if player_camera: # Vérifie que la caméra existe avant d'utiliser ses données
		var cam_pos = player_camera.global_position # Position globale actuelle de la caméra
		var screen_size = get_viewport_rect().size # Taille de l'écran (viewport) en pixels
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size) # Rectangle représentant la zone visible centrée sur la caméra

		visible = visible_zone.has_point(global_position) # Rend le nœud visible seulement s'il est dans la zone caméra


# --- DÉGÂTS AU JOUEUR ---
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage()  # Inflige des dégâts au corps touché (le joueur)
		print("hit 2") # Message de debug indiquant le contact avec le spike 2
