extends StaticBody2D

# --- VARIABLES EXPORTÉES ---
@export var cassable := true # Si vrai, le bloc peut être activé (frappé par le joueur)
@export var sprite_actif: Texture2D # Texture affichée quand le bloc est encore actif (non frappé)
@export var sprite_vide: Texture2D # Texture affichée après que le bloc a été frappé (bloc vide)
@onready var sprite := $Sprite2D # Référence au nœud Sprite2D du bloc
@export var piece_scene: PackedScene # Scène de la pièce à faire apparaître quand le bloc est frappé

# --- VARIABLES D'ÉTAT ---
var active := true # Indique si le bloc est encore actif (pas encore frappé)


# --- FONCTION D'ACTIVATION (FRAPPE) ---
func casser():
	if not active: # Si le bloc a déjà été frappé, on ne fait rien
		return
	if cassable: # Si le bloc est autorisé à réagir à une frappe
		active = false # Marque le bloc comme désactivé (ne peut plus être frappé)
		sprite.texture = sprite_vide # Change la texture pour afficher le bloc vide
		var tween = create_tween() # Crée un tween pour l'animation de choc
		tween.tween_property(self, "position:y", position.y - 6, 0.05) # Monte le bloc de 6 pixels en 0.05s
		tween.tween_property(self, "position:y", position.y, 0.05) # Redescend le bloc à sa position d'origine en 0.05s

	if piece_scene: # Vérifie qu'une scène de pièce est bien assignée
		var piece = piece_scene.instantiate() # Instancie la scène de la pièce
		get_tree().current_scene.add_child(piece) # Ajoute la pièce comme enfant de la scène courante

		# Positionne la pièce juste au-dessus du bloc AVANT de lancer l'animation
		piece.global_position = global_position + Vector2(0, -16) # Place la pièce 16 pixels au-dessus du bloc

		# Lance l'animation de la pièce (montée puis descente)
		piece.start_animation()

# --- INITIALISATION ---
func _ready() -> void:
	pass # Aucune initialisation nécessaire au démarrage
