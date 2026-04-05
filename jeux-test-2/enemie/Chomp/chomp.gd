extends AnimatableBody2D

# --- RÉFÉRENCES ---
@onready var anim_sprite = $AnimatedSprite2D # Référence au sprite animé du Chomp

# --- PARAMÈTRES EXPORTÉS ---
@export var fall_speed := 500.0 # Vitesse de chute du Chomp vers le bas (pixels/seconde)
@export var rise_speed := 100.0 # Vitesse de remontée du Chomp vers sa position initiale (pixels/seconde)
@export var wait_time := 0.5  # Temps d'attente en secondes avant de remonter après l'impact
@export var fall_distance := 210.0 # Nombre de pixels maximum que le Chomp descend avant de s'arrêter

# --- VARIABLES D'ÉTAT ---
var is_falling := false # Vrai si le Chomp est en train de tomber vers le bas
var is_rising := false # Vrai si le Chomp est en train de remonter vers sa position initiale
var start_position := Vector2.ZERO # Position de départ mémorisée pour pouvoir y revenir


# --- INITIALISATION ---
func _ready():
	start_position = global_position # Sauvegarde la position initiale du Chomp au démarrage
	anim_sprite.play("idle") # Lance l'animation d'attente au départ
	sync_to_physics = true # Nécessaire pour que move_and_collide pousse correctement le joueur
	collision_mask = 3 # Layers 1+2 — le joueur peut monter dessus quand le Chomp est au repos


# --- PHYSIQUE & DÉPLACEMENT ---
func _physics_process(delta):
	if is_falling:
		collision_mask = 4 # Layer 3 — détecte le sol (TileMap layer 255) mais pas le joueur (layers 1+2)
		var collision = move_and_collide(Vector2(0, fall_speed * delta)) # Tombe sans bloquer sur le joueur
		if collision != null or global_position.y >= start_position.y + fall_distance: # A touché le sol ou atteint la distance max
			if global_position.y > start_position.y + fall_distance: # Corrige si dépassement de la distance max
				global_position.y = start_position.y + fall_distance
			is_falling = false # Arrête la phase de chute
			anim_sprite.play("impact") # Joue l'animation d'impact au sol
			await get_tree().create_timer(wait_time).timeout # Attend avant de remonter
			is_rising = true # Passe en phase de remontée
			anim_sprite.play("rise") # Lance l'animation de remontée

	elif is_rising:
		collision_mask = 4 # Layer 3 — on ne bloque pas sur le joueur (sinon le Chomp s'arrête immédiatement car le joueur est posé dessus)
		move_and_collide(Vector2(0, -rise_speed * delta)) # Remonte librement ; le joueur est porté automatiquement par get_platform_velocity() de move_and_slide()
		if global_position.y <= start_position.y + 5: # Vérifie si le Chomp est revenu à sa position initiale
			global_position = start_position # Replace exactement à la position initiale
			is_rising = false # Arrête la phase de remontée
			anim_sprite.play("idle") # Repasse à l'animation d'attente


# --- DÉTECTION DE LA ZONE DE DÉCLENCHEMENT ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Vérifie que c'est bien le joueur qui entre dans la zone
		if not is_falling and not is_rising: # Déclenche la chute seulement si le Chomp est au repos
			is_falling = true # Active la phase de chute
			anim_sprite.play("fall") # Lance l'animation de chute


# --- DÉTECTION DE LA ZONE DE DÉTECTION (pré-alerte) ---
func _on_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Vérifie que c'est bien le joueur qui entre dans la zone de détection
		if not is_falling and not is_rising: # Réagit seulement si le Chomp est au repos
			anim_sprite.play("detection") # Joue l'animation d'alerte (le Chomp "remarque" le joueur)


# --- DÉGÂTS AU JOUEUR ---
func _on_damage_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"): # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage() # Inflige des dégâts au corps (le joueur)
		#print("hit chomp") # Message de debug


# --- FIN DE LA DÉTECTION ---
func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player": # Vérifie que c'est bien le joueur qui quitte la zone de détection
		if not is_falling and not is_rising: # Réagit seulement si le Chomp est au repos
			anim_sprite.play("idle") # Repasse à l'animation d'attente quand le joueur s'éloigne
