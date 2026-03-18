extends Area2D

# --- RÉFÉRENCES ---
@onready var player_camera := get_viewport().get_camera_2d() # Récupère la caméra 2D active dans le viewport
@onready var speed = -2 # Vitesse horizontale initiale de la chauve-souris (négatif = vers la gauche)
@onready var left_limit = $"../Left Limite" # Nœud marquant la limite gauche du déplacement
@onready var right_limit = $"../Right Limite" # Nœud marquant la limite droite du déplacement
@onready var animated_sprite = $AnimatedSprite2D # Référence au sprite animé de la chauve-souris

# --- VARIABLES D'ÉTAT ---
var invincible_to_player := false # Vrai si l'ennemi est temporairement invincible au joueur (après un saut dessus)
var damage : = false # Vrai si le joueur a déjà subi des dégâts (pour éviter les doubles hits)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# --- LOGIQUE DE VISIBILITÉ ---
func _process(delta: float) -> void:
	if player_camera: # Vérifie que la caméra existe avant d'utiliser ses données
		var cam_pos = player_camera.global_position # Position globale actuelle de la caméra
		var screen_size = get_viewport_rect().size # Taille de l'écran (viewport) en pixels
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size) # Rectangle représentant la zone visible centrée sur la caméra
		visible = visible_zone.has_point(global_position) # Rend le nœud visible seulement s'il est dans la zone caméra
	if visible:
		#print("vue")
		pass # Emplacement réservé si une logique visible doit être ajoutée

# --- DÉGÂTS AU JOUEUR PAR CONTACT ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not invincible_to_player: # Agit seulement si c'est le joueur ET que l'ennemi n'est pas invincible
		if body.has_method("take_damage"):  # Vérifie que le joueur possède une méthode de prise de dégâts
			body.take_damage()  # Inflige des dégâts au joueur
			damage = true  # Marque que des dégâts ont été infligés (empêche le double hit)
			print("hit mobs 1 mouv") # Message de debug indiquant le contact


# --- DÉPLACEMENT ET REBOND AUX LIMITES ---
func  _physics_process(delta: float) -> void:
	global_position.x += speed # Déplace la chauve-souris horizontalement selon sa vitesse
	if global_position.x >= right_limit.global_position.x: # Si la chauve-souris atteint la limite droite
		speed = -speed # Inverse la direction (repart vers la gauche)
		animated_sprite.flip_h = false # Oriente le sprite vers la gauche (pas de flip)
	elif global_position.x <= left_limit.global_position.x: # Si la chauve-souris atteint la limite gauche
		speed = -speed # Inverse la direction (repart vers la droite)
		animated_sprite.flip_h = true # Oriente le sprite vers la droite (avec flip horizontal)

# --- SAUT DU JOUEUR SUR L'ENNEMI ---
func _on_top_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not damage : # Agit seulement si c'est le joueur et qu'aucun dégât n'a déjà été infligé
		if body.has_method("bounce"): # Vérifie que le joueur possède une méthode de rebond
			body.bounce() # Fait rebondir le joueur vers le haut
			invincible_to_player = true # Rend l'ennemi temporairement invincible pour éviter un double déclenchement
		queue_free() # Supprime l'ennemi de la scène après le saut dessus
