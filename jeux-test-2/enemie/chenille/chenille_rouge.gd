extends CharacterBody2D

# --- PARAMÈTRES EXPORTÉS ---
@export var speed := 40 # Vitesse de déplacement horizontal de la chenille rouge (pixels/seconde)
@export var gravity := 800 # Force de gravité appliquée à la chenille rouge (pixels/seconde²)

# --- VARIABLES D'ÉTAT ---
var on_screen := false # Vrai si la chenille est visible à l'écran (active uniquement si à l'écran)

var direction := -1  # Direction horizontale : -1 = gauche, 1 = droite

# --- RÉFÉRENCES ---
@onready var ground_check = $RayCast2D # RayCast2D qui détecte s'il y a du sol devant la chenille
@onready var wall_check = $WallCheck # RayCast2D qui détecte s'il y a un mur dans la direction du déplacement
@onready var sprite = $death/AnimatedSprite2D # Référence au sprite animé de la chenille rouge
@onready var player = get_tree().get_first_node_in_group("player") # Référence au joueur (non utilisée activement ici)


# --- INITIALISATION ---
func _ready():
	_update_raycast_positions() # Positionne les raycasts selon la direction initiale
	sprite.flip_h = direction > 0 # Retourne le sprite si la direction est vers la droite


# --- PHYSIQUE ET DÉPLACEMENT ---
func _physics_process(delta):
	if not is_on_floor(): # Si la chenille n'est pas au sol
		velocity.y += gravity * delta # Applique la gravité pour la faire tomber
	else:
		velocity.y = 0 # Stoppe la chute quand le sol est atteint

	if  not on_screen: # Si la chenille n'est pas encore à l'écran
		return # Ne fait rien, attend d'être visible

	# Si pas de sol ou mur devant → demi-tour
	if not ground_check.is_colliding(): # Si le raycast sol ne détecte pas de terrain (bord de plateforme)
		#print("vue sol")
		direction *= -1 # Inverse la direction pour faire demi-tour
		sprite.flip_h = direction > 0 # Met à jour l'orientation du sprite
		_update_raycast_positions() # Repositionne les raycasts pour la nouvelle direction

	if wall_check.is_colliding(): # Si le raycast mur détecte un obstacle devant
		#print("vue mur")
		direction *= -1 # Inverse la direction pour faire demi-tour
		sprite.flip_h = direction > 0 # Met à jour l'orientation du sprite
		_update_raycast_positions() # Repositionne les raycasts pour la nouvelle direction


	# Déplacement horizontal
	velocity.x = speed * direction # Applique la vitesse horizontale dans la direction courante
	move_and_slide() # Déplace la chenille en tenant compte des collisions

# --- MISE À JOUR DES RAYCASTS ---
func _update_raycast_positions():
	var offset_x = 10 # Décalage horizontal des raycasts par rapport au centre de la chenille
	ground_check.position.x = offset_x * direction # Place le raycast sol devant la chenille selon sa direction
	wall_check.position.x = offset_x * direction # Place le raycast mur devant la chenille selon sa direction

	# Le sol → toujours vers le bas
	ground_check.target_position = Vector2(0, 16) # Le raycast sol pointe vers le bas (16 pixels)

	# Le mur → dans la direction du déplacement (8 pixels vers la gauche ou droite)
	wall_check.target_position = Vector2(1 * direction, 0) # Le raycast mur pointe dans la direction de déplacement

# --- DÉGÂTS AU JOUEUR ---
func _on_death_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage()  # Inflige des dégâts au corps touché (le joueur)
		#print("hit chenille bleu")


# --- ACTIVATION À L'APPARITION À L'ÉCRAN ---
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true  # Active la chenille dès qu'elle entre dans la zone visible de la caméra
