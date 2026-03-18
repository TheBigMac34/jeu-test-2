extends StaticBody2D


# --- VARIABLES EXPORTÉES ---
@export var cassable := true # Si vrai, le bloc peut être cassé par le joueur


# --- FONCTION DE DESTRUCTION ---
func casser():
	if cassable: # Vérifie que le bloc est autorisé à être cassé
		$AudioStreamPlayer.play() # Joue le son de destruction du bloc
		var tween = create_tween() # Crée un tween pour animer le bloc
		tween.tween_property(self, "position:y", position.y - 6, 0.05) # Monte le bloc de 6 pixels en 0.05s (animation de choc)
		tween.tween_property(self, "position:y", position.y, 0.05) # Redescend le bloc à sa position d'origine en 0.05s
		tween.finished.connect(queue_free) # Supprime le nœud du jeu une fois l'animation terminée


# --- INITIALISATION ---
func _ready() -> void:
	pass # Aucune initialisation nécessaire au démarrage


# --- BOUCLE PRINCIPALE ---
func _process(delta: float) -> void:
	pass # Aucun traitement nécessaire chaque frame
