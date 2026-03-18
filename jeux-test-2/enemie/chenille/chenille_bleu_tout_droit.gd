extends CharacterBody2D

# --- PARAMÈTRES EXPORTÉS ---
@export var speed := 60 # Vitesse de déplacement horizontal de la chenille (pixels/seconde)
@export var group_to_activate: String # Nom du groupe de mobs à activer quand le leader entre à l'écran
@export var leader_chaine_de_4 := false # Vrai si cette chenille est le leader d'une chaîne de 4 (version 1)
@export var leader_chaine_de_4v2 := false # Vrai si cette chenille est le leader d'une chaîne de 4 (version 2)

# --- VARIABLES D'ÉTAT ---
var has_been_visible := false # Vrai si la chenille est déjà apparue à l'écran au moins une fois
var is_active := false # Vrai si la chenille est activée et doit se déplacer

var direction := -1  # Direction horizontale : -1 = gauche, 1 = droite

# --- CONSTANTES ---
const Y_LIMITE = 100  # Valeur Y limite en dessous de laquelle la chenille est considérée comme tombée (hors niveau)


# --- INITIALISATION ---
func _ready():
	pass # Aucune initialisation nécessaire au démarrage


# --- ACTIVATION À L'APPARITION À L'ÉCRAN ---
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	has_been_visible = true # Marque que la chenille a déjà été visible
	is_active = true # Active le déplacement de la chenille
	#print("entred screen")

	var is_leader := leader_chaine_de_4 or leader_chaine_de_4v2 # Vrai si cette chenille est un leader de chaîne
	if not is_leader:
		return  # Seul un leader active le groupe, les autres ignorent cette logique


	if group_to_activate.strip_edges() == "": # Vérifie que le nom de groupe n'est pas vide ou que des espaces
		# print("⚠️ group_to_activate vide sur", name)
		return # Ne fait rien si aucun groupe n'est configuré

	var mobs := get_tree().get_nodes_in_group(group_to_activate) # Récupère tous les mobs du groupe à activer
	# print("Leader", name, "active", mobs.size(), "mobs du groupe", group_to_activate)

	for mob in mobs: # Parcourt tous les mobs du groupe
		mob.is_active = true # Active chaque mob du groupe


# --- PHYSIQUE ET DÉPLACEMENT ---
func _physics_process(delta):
	if not is_active: # Si la chenille n'est pas encore activée
		return # Ne fait rien, attend l'activation

	if position.y > Y_LIMITE: # Si la chenille est tombée trop bas (hors du niveau)
		queue_free() # Supprime la chenille de la scène
		#print("MORT")
	if not is_on_floor(): # Si la chenille n'est pas au sol
		velocity += get_gravity() * delta # Applique la gravité pour la faire tomber
	velocity.x = speed * direction # Applique la vitesse horizontale dans la direction courante
	move_and_slide() # Déplace la chenille en tenant compte des collisions


# --- DÉGÂTS AU JOUEUR ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Vérifie que le corps entré peut recevoir des dégâts
		body.take_damage()  # Inflige des dégâts au corps touché (le joueur)
		# print("hit chenille bleu")
