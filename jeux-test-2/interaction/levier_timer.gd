extends Area2D

# --- PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur) ---
@export var bat_scene: PackedScene                         # Scène de chauve-souris à spawner
@export var touche_activation: String = "interact"        # Touche pour activer le levier (X Xbox / Carré PS)
@export var duree_timer: float = 10.0                      # Durée en secondes avant que les mobs disparaissent et le levier se réinitialise

# --- RÉFÉRENCES ---
@onready var animated_sprite = $AnimatedSprite2D          # Référence au sprite animé du levier
@onready var emote = $Sprite2D                            # Emote X affiché au-dessus du joueur quand il est proche

# --- VARIABLES D'ÉTAT ---
var active := false                                        # True si le levier est actuellement activé
var joueur_proche := false                                 # True si le joueur est dans la zone de détection
var mobs_spawnes: Array = []                              # Liste des mobs spawnés pour pouvoir les supprimer au reset


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if joueur_proche and not active and Input.is_action_just_pressed(touche_activation):
		activer()


# --- ACTIVATION DU LEVIER ---
func activer() -> void:
	print("levier_timer: activer() appelé")
	print("levier_timer: bat_scene = ", bat_scene)
	print("levier_timer: enfants = ", get_children())
	active = true
	emote.visible = false                                  # Cache l'emote pendant l'activation
	animated_sprite.play("action")                         # Joue l'animation du levier

	# Spawn les chauve-souris à chaque Marker2D enfant
	for child in get_children():
		print("levier_timer: enfant trouvé → ", child.name, " (", child.get_class(), ")")
		if child is Marker2D:
			if bat_scene == null:
				push_error("Levier Timer : bat_scene n'est pas assigné dans l'inspecteur !")
				return
			var bat = bat_scene.instantiate()
			get_parent().add_child(bat)
			bat.global_position = child.global_position
			if "start_pos" in bat:
				bat.start_pos = bat.global_position
				bat.target_pos = bat.global_position + bat.move_direction
			mobs_spawnes.append(bat)                       # Garde une référence au mob pour pouvoir le supprimer plus tard

	# Lance le timer de réinitialisation
	await get_tree().create_timer(duree_timer).timeout
	_reset()


# --- RÉINITIALISATION DU LEVIER ---
func _reset() -> void:
	# Supprime tous les mobs spawnés encore en vie
	for mob in mobs_spawnes:
		if is_instance_valid(mob):                         # Vérifie que le mob existe encore (il peut avoir été tué par le joueur)
			mob.queue_free()
	mobs_spawnes.clear()                                   # Vide la liste

	# Réinitialise le levier pour qu'il soit réactivable
	active = false
	animated_sprite.play("default")                        # Remet l'animation initiale
	if joueur_proche:                                      # Si le joueur est toujours dans la zone, réaffiche l'emote
		emote.visible = true


# --- DÉTECTION DU JOUEUR ---
func _on_body_entered(body: Node2D) -> void:
	print("levier_timer: body_entered → ", body.name)
	if body.name == "Player":
		joueur_proche = true
		if not active:
			emote.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		joueur_proche = false
		emote.visible = false
