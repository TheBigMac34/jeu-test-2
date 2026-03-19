extends Button

# --- VARIABLES EXPORTÉES ---
@export var hover_scale := 1.1   # facteur d'agrandissement au survol/focus
@export var duration := 0.10     # durée de l'animation en secondes
@export var level_id := "1_2"   # identifiant du niveau, utilisé pour construire les clés de sauvegarde

# --- VARIABLES INTERNES ---
var base_scale: Vector2          # échelle d'origine mémorisée au démarrage
var tween: Tween                 # référence au tween en cours pour pouvoir l'annuler


# --- LECTURE DU FICHIER DE SAUVEGARDE ---
func _load_save_file() -> Dictionary:
	if not FileAccess.file_exists(Global.save_path): # vérifie si le fichier de sauvegarde existe
		return {}
	var f := FileAccess.open(Global.save_path, FileAccess.READ)
	if not f:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


# --- MISE À JOUR VISUELLE SELON LES MÉDAILLES ---
func update_visual():
	var data := _load_save_file() # charge les données de sauvegarde pour lire les médailles

	var done   := bool(data.get("level_" + level_id + "_done",   false)) # vrai si le niveau a déjà été complété
	var silver := bool(data.get("level_" + level_id + "_silver", false)) # vrai si la médaille argent a été obtenue
	var gold   := bool(data.get("level_" + level_id + "_gold",   false)) # vrai si la médaille or a été obtenue

	var couleur : Color
	if gold:
		couleur = Color("dfec11")   # or    → jaune
	elif silver:
		couleur = Color("c0c0c0")   # argent → gris clair
	elif done:
		couleur = Color("cd7f32")   # bronze → marron/cuivre
	else:
		couleur = Color.WHITE       # pas encore fait → blanc

	add_theme_color_override("font_color",         couleur) # applique la couleur au texte normal du bouton
	add_theme_color_override("font_hover_color",   couleur) # applique la même couleur au texte en état de survol
	add_theme_color_override("font_pressed_color", couleur) # applique la même couleur au texte en état de clic


# --- INITIALISATION ---
func _ready() -> void:
	update_visual()                           # applique la couleur correcte dès le chargement
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
