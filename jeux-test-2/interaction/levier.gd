extends Area2D

# --- PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur) ---
@export var bat_scene: PackedScene                         # Scène de chauve-souris à spawner (mobs_mouv_1.tscn ou mobs_imo_1.tscn)
@export var touche_activation: String = "interact"         # Touche pour activer le levier (défaut : X Xbox / Carré PS)

# --- RÉFÉRENCES ---
@onready var animated_sprite = $AnimatedSprite2D            # Référence au sprite animé du levier
@onready var emote = $Sprite2D                              # Emote X affiché au-dessus du joueur quand il est proche

# --- VARIABLES D'ÉTAT ---
var active := false                                        # True si le levier a déjà été activé (évite la double activation)
var joueur_proche := false                                 # True si le joueur est dans la zone de détection du levier


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	# Si le joueur est proche, que le levier n'est pas encore activé, et qu'il appuie sur la touche
	if joueur_proche and not active and Input.is_action_just_pressed(touche_activation):
		activer()


# --- ACTIVATION DU LEVIER ---
func activer() -> void:
	active = true                                          # Marque le levier comme activé (ne peut être déclenché qu'une fois)
	animated_sprite.play("action")                         # Joue l'animation du levier une seule fois (loop: false)
	emote.visible = false                                  # Cache l'emote définitivement après activation
	print("Levier activé !")                               # Debug

	# Parcourt tous les enfants du levier qui sont des Marker2D → chaque Marker2D = un point de spawn
	for child in get_children():
		if child is Marker2D:
			if bat_scene == null:                          # Sécurité : vérifie que la scène est bien assignée
				push_error("Levier : bat_scene n'est pas assigné dans l'inspecteur !")
				return

			var bat = bat_scene.instantiate()              # Crée une instance de la chauve-souris
			get_parent().add_child(bat)                    # L'ajoute dans le niveau (même parent que le levier)
			bat.global_position = child.global_position    # La place à la position du Marker2D

			# Si c'est une chauve-souris mobile : recalcule le centre et la cible depuis sa nouvelle position
			if "start_pos" in bat:
				bat.start_pos = bat.global_position
				bat.target_pos = bat.global_position + bat.move_direction


# --- DÉTECTION DU JOUEUR ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":                              # Le joueur entre dans la zone du levier
		joueur_proche = true
		if not active:                                         # Affiche l'emote seulement si le levier n'est pas encore activé
			emote.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":                              # Le joueur quitte la zone du levier
		joueur_proche = false
		emote.visible = false                              # Cache l'emote quand le joueur s'éloigne
