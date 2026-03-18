extends Button

# --- VARIABLES EXPORTÉES (configurables depuis l'éditeur) ---
@export var hover_scale := 1.1   # facteur d'agrandissement du bouton lors du survol (10% plus grand)
@export var duration := 0.10     # durée en secondes de l'animation d'agrandissement/réduction

# --- VARIABLES INTERNES ---
var base_scale: Vector2          # échelle d'origine du bouton, mémorisée au démarrage
var tween: Tween                 # référence au tween d'animation en cours pour pouvoir l'annuler

@export var level_id := "1_1"   # identifiant du niveau, utilisé pour construire les clés de sauvegarde

# --- COULEURS EXPORTÉES ---
@export var normal_color: Color = Color.WHITE              # couleur du texte par défaut (niveau non commencé)
@export var gold_color: Color = Color("dfec11")            # couleur or du texte quand la médaille or est obtenue


# --- INITIALISATION ---
func _ready() -> void:
	update_visual()                          # applique la couleur correcte dès le chargement selon la sauvegarde
	pivot_offset = size / 2                  # centre le pivot du bouton pour que l'animation de scale soit centrée
	base_scale = scale                       # mémorise l'échelle initiale pour pouvoir y revenir après le hover

	# Souris
	mouse_entered.connect(_apply_hover)      # connecte le signal de survol souris à l'animation d'agrandissement
	mouse_exited.connect(_remove_hover)      # connecte la sortie de survol à l'animation de réduction

	# Manette / clavier (focus)
	focus_entered.connect(_apply_hover)      # connecte le signal de focus (navigation clavier/manette) à l'animation
	focus_exited.connect(_remove_hover)      # connecte la perte de focus à l'animation de réduction

	# Important : autoriser le focus
	focus_mode = Control.FOCUS_ALL           # permet au bouton d'être sélectionné via clavier, manette et souris


# --- LECTURE DU FICHIER DE SAUVEGARDE ---
func _load_save_file() -> Dictionary:
	if not FileAccess.file_exists(Global.save_path): # vérifie si le fichier de sauvegarde existe
		return {}                                     # retourne un dictionnaire vide si pas de sauvegarde
	var f := FileAccess.open(Global.save_path, FileAccess.READ) # ouvre le fichier de sauvegarde en lecture
	if not f:                                                    # vérifie que l'ouverture a réussi
		return {}                                                # retourne vide si le fichier ne peut pas être ouvert
	var parsed = JSON.parse_string(f.get_as_text())              # désérialise le contenu JSON du fichier
	f.close()                                                    # ferme le fichier après lecture
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}   # retourne le dictionnaire parsé, ou {} si invalide


# --- ANIMATIONS DE HOVER ---
func _apply_hover():
	_kill_tween()                                                           # annule toute animation en cours avant d'en lancer une nouvelle
	tween = create_tween()                                                  # crée un nouveau tween pour l'animation
	tween.tween_property(self, "scale", base_scale * hover_scale, duration) # anime l'agrandissement du bouton vers hover_scale


func _remove_hover():
	_kill_tween()                                                 # annule toute animation en cours
	tween = create_tween()                                        # crée un nouveau tween pour revenir à la taille normale
	tween.tween_property(self, "scale", base_scale, duration)     # anime la réduction du bouton vers l'échelle d'origine


func _kill_tween():
	if tween and tween.is_valid(): # vérifie que le tween existe et est encore actif
		tween.kill()               # arrête et détruit le tween en cours pour éviter les conflits d'animation


# --- MISE À JOUR VISUELLE SELON LES MÉDAILLES ---
func update_visual():
	var data := _load_save_file() # charge les données de sauvegarde pour lire les médailles

	var done   := bool(data.get("level_1_1_done",   false)) # vrai si le niveau 1-1 a déjà été complété
	var silver := bool(data.get("level_1_1_silver", false)) # vrai si la médaille argent a été obtenue sur ce niveau
	var gold   := bool(data.get("level_1_1_gold",   false)) # vrai si la médaille or a été obtenue sur ce niveau

	# On choisit la couleur selon la meilleure médaille obtenue
	var couleur : Color
	if gold:
		couleur = Color("dfec11")       # Or    → jaune
	elif silver:
		couleur = Color("c0c0c0")       # Argent → gris clair
	elif done:
		couleur = Color("cd7f32")       # Bronze → marron/cuivre
	else:
		couleur = Color.WHITE           # Pas encore fait → blanc

	add_theme_color_override("font_color",         couleur) # applique la couleur au texte normal du bouton
	add_theme_color_override("font_hover_color",   couleur) # applique la même couleur au texte en état de survol
	add_theme_color_override("font_pressed_color", couleur) # applique la même couleur au texte en état de clic
