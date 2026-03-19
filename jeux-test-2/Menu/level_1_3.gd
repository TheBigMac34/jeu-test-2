extends Button

# --- VARIABLES EXPORTÉES ---
@export var hover_scale := 1.1   # facteur d'agrandissement au survol/focus
@export var duration := 0.10     # durée de l'animation en secondes

# --- VARIABLES INTERNES ---
var base_scale: Vector2          # échelle d'origine mémorisée au démarrage
var tween: Tween                 # référence au tween en cours pour pouvoir l'annuler


# --- INITIALISATION ---
func _ready() -> void:
	pivot_offset = size / 2                   # centre le pivot pour que le scale soit centré
	base_scale = scale                        # mémorise l'échelle initiale

	# Souris
	mouse_entered.connect(_apply_hover)       # agrandit le bouton au survol souris
	mouse_exited.connect(_remove_hover)       # réduit le bouton quand la souris part

	# Manette / clavier (focus)
	focus_entered.connect(_apply_hover)       # agrandit le bouton quand il reçoit le focus
	focus_exited.connect(_remove_hover)       # réduit le bouton quand il perd le focus

	focus_mode = Control.FOCUS_ALL            # autorise la sélection via clavier, manette et souris


# --- ANIMATION D'AGRANDISSEMENT ---
func _apply_hover():
	_kill_tween()                                                            # annule l'animation précédente
	tween = create_tween()                                                   # crée un nouveau tween
	tween.tween_property(self, "scale", base_scale * hover_scale, duration)  # anime vers la taille agrandie


# --- ANIMATION DE RÉDUCTION ---
func _remove_hover():
	_kill_tween()                                                  # annule l'animation précédente
	tween = create_tween()                                         # crée un nouveau tween
	tween.tween_property(self, "scale", base_scale, duration)      # anime vers la taille normale


# --- ARRÊT DU TWEEN EN COURS ---
func _kill_tween():
	if tween and tween.is_valid():  # vérifie que le tween existe et est actif
		tween.kill()                # arrête le tween pour éviter les conflits
