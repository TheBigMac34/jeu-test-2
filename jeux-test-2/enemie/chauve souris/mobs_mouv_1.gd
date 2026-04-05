extends Node2D

# --- PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur) ---
@export var move_direction: Vector2 = Vector2(100, 0)      # Direction ET distance du déplacement (ex: Vector2(150,0) = 150px horizontal, Vector2(0,100) = 100px vertical)
@export var move_speed: float = 40.0                      # Vitesse de déplacement en pixels par seconde

# --- RÉFÉRENCES ---
@onready var player_camera := get_viewport().get_camera_2d() # Récupère la caméra 2D active dans le viewport
@onready var animated_sprite = $AnimatedSprite2D           # Référence au sprite animé de la chauve-souris
@onready var start_pos: Vector2 = global_position          # Position de départ, centre de l'oscillation
@onready var target_pos: Vector2 = global_position + move_direction # Position cible initiale

# --- VARIABLES D'ÉTAT ---
var invincible_to_player := false                          # Vrai si l'ennemi est temporairement invincible au joueur (après un saut dessus)
var damage := false                                        # Vrai si le joueur a déjà subi des dégâts (pour éviter les doubles hits)


func _ready() -> void:
	pass


# --- LOGIQUE DE VISIBILITÉ ---
func _process(delta: float) -> void:
	if player_camera:                                      # Vérifie que la caméra existe avant d'utiliser ses données
		var cam_pos = player_camera.global_position        # Position globale actuelle de la caméra
		var screen_size = get_viewport_rect().size         # Taille de l'écran (viewport) en pixels
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size) # Rectangle représentant la zone visible centrée sur la caméra
		visible = visible_zone.has_point(global_position)  # Rend le nœud visible seulement s'il est dans la zone caméra


# --- DÉPLACEMENT ALLER-RETOUR ---
func _physics_process(delta: float) -> void:
	# Oriente le sprite selon la direction horizontale de déplacement
	if target_pos.x > global_position.x:                  # Se déplace vers la droite
		animated_sprite.flip_h = true                      # Flip vers la droite
	elif target_pos.x < global_position.x:                # Se déplace vers la gauche
		animated_sprite.flip_h = false                     # Flip vers la gauche

	global_position = global_position.move_toward(target_pos, move_speed * delta) # Avance vers la cible

	if global_position == target_pos:                      # Cible atteinte : on inverse la direction
		if target_pos == start_pos:                        # On était en train de revenir au départ
			target_pos = start_pos + move_direction        # Repart vers la destination
		else:                                              # On était en train d'aller à la destination
			target_pos = start_pos                         # Repart vers le départ



# --- SAUT DU JOUEUR SUR L'ENNEMI ---
func _on_top_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not damage:               # Agit seulement si c'est le joueur et qu'aucun dégât n'a déjà été infligé
		if body.has_method("bounce"):                      # Vérifie que le joueur possède une méthode de rebond
			body.bounce()                                  # Fait rebondir le joueur vers le haut
			body.can_dash = true                           # Recharge le dash du joueur
		invincible_to_player = true                        # Rend l'ennemi temporairement invincible pour éviter un double déclenchement
		queue_free()                                       # Supprime l'ennemi de la scène après le saut dessus

# --- DÉGÂTS AU JOUEUR PAR CONTACT ---

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not invincible_to_player: # Agit seulement si c'est le joueur ET que l'ennemi n'est pas invincible
		if body.has_method("take_damage"):                 # Vérifie que le joueur possède une méthode de prise de dégâts
			body.take_damage()                             # Inflige des dégâts au joueur
			damage = true                                  # Marque que des dégâts ont été infligés (empêche le double hit)
			print("hit mobs 1 mouv")                       # Message de debug indiquant le contact
