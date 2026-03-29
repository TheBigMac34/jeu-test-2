extends CharacterBody2D

# --- RÉFÉRENCES ---
@onready var anim_sprite = $AnimatedSprite2D # Référence au sprite animé du Chomp

# --- PARAMÈTRES EXPORTÉS ---
@export var fall_speed := 500.0 # Vitesse de chute du Chomp vers le bas (pixels/seconde)
@export var rise_speed := 100.0 # Vitesse de remontée du Chomp vers sa position initiale (pixels/seconde)
@export var wait_time := 0.5  # Temps d'attente en secondes avant de remonter après l'impact
@export var fall_distance := 210.0 # Nombre de pixels maximum que le Chomp descend avant de s'arrêter

# --- VARIABLES D'ÉTAT ---
var player_in_zone := false # Indique si le joueur est dans la zone de détection (non utilisé activement)
var is_falling := false # Vrai si le Chomp est en train de tomber vers le bas
var is_rising := false # Vrai si le Chomp est en train de remonter vers sa position initiale
var start_position := Vector2.ZERO # Position de départ mémorisée pour pouvoir y revenir


# --- INITIALISATION ---
func _ready():
	start_position = global_position # Sauvegarde la position initiale du Chomp au démarrage
	anim_sprite.play("idle") # Lance l'animation d'attente au départ


# --- PHYSIQUE & DÉPLACEMENT ---
func _physics_process(delta):
	if is_falling: # Si le Chomp est en phase de chute
		velocity.y = fall_speed # Applique la vitesse de chute vers le bas
		move_and_slide() # Déplace le Chomp en tenant compte des collisions
		if is_on_floor() or global_position.y >= start_position.y + fall_distance: # Vérifie si le Chomp a touché le sol ou atteint la distance maximale de chute
			is_falling = false # Arrête la phase de chute
			anim_sprite.play("impact") # Joue l'animation d'impact au sol
			await get_tree().create_timer(wait_time).timeout # Attend le délai configuré avant de remonter
			is_rising = true # Passe en phase de remontée
			anim_sprite.play("rise") # Lance l'animation de remontée

	elif is_rising: # Si le Chomp est en phase de remontée
		var direction = (start_position - global_position).normalized() # Calcule la direction normalisée vers la position initiale
		velocity = direction * rise_speed # Applique la vitesse de remontée dans la bonne direction
		move_and_slide() # Déplace le Chomp en tenant compte des collisions
		if global_position.distance_to(start_position) < 5: # Vérifie si le Chomp est suffisamment proche de sa position initiale
			global_position = start_position # Replace exactement le Chomp à sa position initiale
			velocity = Vector2.ZERO # Stoppe tout mouvement résiduel
			is_rising = false # Arrête la phase de remontée
			anim_sprite.play("idle") # Repasse à l'animation d'attente

	else:
		velocity = Vector2.ZERO # Aucun mouvement si le Chomp est ni en chute ni en remontée


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
			is_falling = false # Ne déclenche pas encore la chute
			anim_sprite.play("detection") # Joue l'animation d'alerte (le Chomp "remarque" le joueur)


# --- DÉGÂTS AU JOUEUR ---
func _on_damage_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage()  # Inflige des dégâts au corps (le joueur)
		print("hit chomp") # Message de debug indiquant le contact avec le Chomp


# --- FIN DE LA DÉTECTION ---
func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player": # Vérifie que c'est bien le joueur qui quitte la zone de détection
		if not is_falling and not is_rising: # Réagit seulement si le Chomp est au repos
			anim_sprite.play("idle") # Repasse à l'animation d'attente quand le joueur s'éloigne
