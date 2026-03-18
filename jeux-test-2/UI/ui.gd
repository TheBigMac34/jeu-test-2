extends CanvasLayer

# --- RÉFÉRENCES AUX NOEUDS UI ---
@onready var life_container = $LifeContainer  # conteneur (HBoxContainer) qui affiche les icônes de vie
@onready var label = $TextureRect/Label       # label affichant le compteur de pièces collectées

# --- PIÈCES OBJECTIF ---
@onready var objectifs_box = $Node/HBoxContainer # conteneur horizontal pour les icônes de pièces objectif
@export var tex_empty: Texture2D                 # texture affichée pour une pièce objectif non encore collectée
@export var tex_full: Texture2D                  # texture affichée pour une pièce objectif collectée
@export var level_id := "Lvl_1_1"               # identifiant du niveau courant, utilisé pour lire les pièces objectif dans Global
@onready var icons := [                          # tableau des 5 TextureRect représentant les pièces objectif dans la barre d'UI
	$Node/HBoxContainer/piece_objectif_vide_1,   # icône de la pièce objectif numéro 1
	$Node/HBoxContainer/piece_objectif_vide_2,   # icône de la pièce objectif numéro 2
	$Node/HBoxContainer/piece_objectif_vide_3,   # icône de la pièce objectif numéro 3
	$Node/HBoxContainer/piece_objectif_vide_4,   # icône de la pièce objectif numéro 4
	$Node/HBoxContainer/piece_objectif_vide_5    # icône de la pièce objectif numéro 5
]

# --- BARRE DE PROGRESSION ---
@onready var bar_fill = $ProgressContainer/BarFill           # sprite de remplissage coloré de la barre de progression
@onready var bar_background = $ProgressContainer/BarBackground # fond blanc/gris de la barre de progression (donne la largeur maximale)
@onready var player_icon = $ProgressContainer/PlayerIcon     # icône représentant le joueur sur la barre de progression
@onready var progress_bar = $ProgressContainer/ProgressBar   # noeud ProgressBar (valeur 0..100)
var best_percent := 0.0                                       # mémorise la meilleure progression atteinte (empêche de "reculer" sur la barre)

# --- VARIABLES POUR LA BARRE DE PROGRESSION ---
var player: Node2D   # référence au noeud joueur, fournie par la scène du niveau via setup_progress()
var start_x := 0.0   # position X du début du niveau (en coordonnées monde), servant d'origine pour le calcul du pourcentage
var end_x := 1.0     # position X de la fin du niveau (en coordonnées monde), servant de borne maximale


# --- CONFIGURATION DE LA BARRE DE PROGRESSION ---
func setup_progress(p: Node2D, level_start_x: float, level_end_x: float) -> void:
	player = p               # stocke la référence au joueur pour pouvoir lire sa position chaque frame
	start_x = level_start_x # définit la borne gauche du niveau pour le calcul de progression
	end_x = level_end_x     # définit la borne droite du niveau pour le calcul de progression


# --- INITIALISATION ---
func _ready() -> void:
	update_vie()                    # génère les icônes de vie dès le chargement de l'UI
	$Fond.hide()                    # cache le fond semi-transparent du menu pause
	$"VBoxContainer/Menu Button".hide()           # cache le bouton Menu (visible uniquement en pause)
	$"VBoxContainer/Restart Button".hide()        # cache le bouton Restart (visible uniquement en pause)
	$"Back Button".hide()           # cache le bouton Retour (visible uniquement en pause)

	# --- NAVIGATION MANETTE DANS LE MENU PAUSE ---
	# Définit l'ordre de navigation au D-pad entre les boutons de pause
	$"Back Button".focus_neighbor_bottom    = $"Back Button".get_path_to($"VBoxContainer/Menu Button")
	$"VBoxContainer/Menu Button".focus_neighbor_top       = $"VBoxContainer/Menu Button".get_path_to($"Back Button")
	$"VBoxContainer/Menu Button".focus_neighbor_bottom    = $"VBoxContainer/Menu Button".get_path_to($"VBoxContainer/Restart Button")
	$"VBoxContainer/Restart Button".focus_neighbor_top    = $"VBoxContainer/Restart Button".get_path_to($"VBoxContainer/Menu Button")


# --- MISE À JOUR CHAQUE FRAME ---
func _process(delta: float) -> void:
	# Détection de la touche pause (Select/Start manette ou Escape clavier)
	# Input.is_action_just_pressed() fonctionne sur le singleton Input, sans passer par les events
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_on_back_button_pressed()   # si déjà en pause → reprendre
		else:
			_on_pause_button_pressed()  # sinon → mettre en pause

	label.text = str(Global.coins) + "/20"  # met à jour le label des pièces avec la valeur actuelle et l'objectif de 20

	# progress bar
	if player != null:                                                                        # ne met à jour la barre que si un joueur a été assigné
		var percent = ((player.global_position.x - start_x) / (end_x - start_x)) * 100.0    # calcule le pourcentage de progression du joueur (0..100)
		progress_bar.value = clamp(percent, 0.0, 100.0)                                       # applique la valeur clampée à la ProgressBar native
		# empêche de reculer : on garde la valeur max atteinte
		best_percent = max(best_percent, percent)                                             # mémorise le meilleur pourcentage atteint pour ne jamais reculer

		# 0..1
		var t = (player.global_position.x - start_x) / (end_x - start_x)  # recalcule t entre 0 et 1 (sans multiplier par 100) pour les calculs de position
		t = clamp(t, 0.0, 1.0)                                              # encadre t entre 0 et 1 pour éviter tout dépassement

		var total_width = bar_background.size.x  # récupère la largeur totale du fond de barre pour calibrer les calculs

		# Remplissage : 0..total_width
		var fill_w = total_width * t  # calcule la largeur de remplissage proportionnelle à la progression (ex: t=0.5 → moitié de la barre)
		bar_fill.size.x = fill_w      # applique la largeur calculée au sprite de remplissage

		# Icône (Sprite2D) : on prend la largeur de la texture
		var tex: Texture2D = player_icon.texture # récupère la texture de l'icône joueur
		var icon_w := 0.0                         # initialise la largeur de l'icône à 0 par défaut
		if tex != null:                           # vérifie que la texture est bien assignée
			icon_w = tex.get_size().x * abs(player_icon.scale.x) # calcule la largeur réelle de l'icône en tenant compte de son échelle

		# Sprite2D est centré, donc on clamp sa position (centre) dans la barre
		var icon_x = clamp(fill_w, 0.0, total_width) # calcule la position X de l'icône en suivant le remplissage, clampée dans la barre
		player_icon.position.x = icon_x              # déplace l'icône joueur sur la barre de progression


# --- MISE À JOUR DE L'AFFICHAGE DES VIES ---
func update_vie():
	# Supprimer les icônes précédentes
	for child in life_container.get_children(): # parcourt tous les enfants du conteneur de vies
		child.queue_free()                       # supprime chaque icône de cœur existante pour éviter les doublons
	# print("nonon")
	# Ajouter autant de vies que dans Global
	for i in Global.vies_actuelles:                 # boucle autant de fois qu'il y a de vies actuelles
		var coeur = TextureRect.new()               # crée un nouveau noeud TextureRect pour représenter une vie
		coeur.texture = preload("res://base de donné image/kenney_pixel-platformer/Tiles/tile_0044.png") # assigne la texture d'icône de cœur
		coeur.expand_mode = TextureRect.EXPAND_KEEP_SIZE # conserve les dimensions originales de la texture (pas d'étirement)
		life_container.add_child(coeur)             # ajoute l'icône de cœur au conteneur de vies




# --- BOUTON PAUSE ---
func _on_pause_button_pressed() -> void:
	get_tree().paused = true        # met le jeu en pause (arrête _process et _physics_process de tous les noeuds)
	$Fond.show()                    # affiche le fond semi-transparent du menu pause
	$"Pause Button".hide()          # cache le bouton Pause (remplacé par les boutons du menu pause)
	$"VBoxContainer/Menu Button".show()           # affiche le bouton pour retourner au menu principal
	$"VBoxContainer/Restart Button".show()        # affiche le bouton pour recommencer le niveau
	$"Back Button".show()           # affiche le bouton pour reprendre la partie
	$"Back Button".grab_focus()     # donne le focus au bouton Reprendre pour la navigation manette
	#print("pause")


# --- BOUTON REPRENDRE ---
func _on_back_button_pressed() -> void:
	get_tree().paused = false       # reprend le jeu (réactive tous les _process)
	$Fond.hide()                    # cache le fond du menu pause
	$"VBoxContainer/Menu Button".hide()           # cache le bouton Menu
	$"VBoxContainer/Restart Button".hide()        # cache le bouton Restart
	$"Back Button".hide()           # cache le bouton Retour
	$"Pause Button".show()          # ré-affiche le bouton Pause


# --- BOUTON MENU PRINCIPAL ---
func _on_menu_button_pressed() -> void:
	Global.clear_checkpoint()                           # efface le checkpoint pour ne pas reprendre en cours de niveau
	Global.coins = 0                                    # remet le compteur de pièces à zéro
	get_tree().paused = false                           # reprend le jeu (nécessaire avant de changer de scène)
	$Fond.hide()                                        # cache le fond du menu pause
	$"VBoxContainer/Menu Button".hide()                               # cache le bouton Menu
	$"VBoxContainer/Restart Button".hide()                            # cache le bouton Restart
	$"Back Button".hide()                               # cache le bouton Retour
	$"Pause Button".show()                              # ré-affiche le bouton Pause (pour la prochaine fois)
	var menu_principale = load("res://Menu/menu_principal.tscn") # charge la scène du menu principal dynamiquement
	get_tree().change_scene_to_packed(menu_principale)           # change la scène vers le menu principal
	print("menu principale")                            # confirme dans la console que le changement de scène est demandé
	Global.last_checkpoint_position = Vector2.ZERO     # réinitialise la position de checkpoint mémorisée
	#print("Menu principale :", menu_principale)


# --- BOUTON RESTART ---
func _on_restart_button_pressed() -> void:
	Global.clear_checkpoint()                           # efface le checkpoint sauvegardé sur le disque
	Global.coins = 0                                    # remet le compteur de pièces à zéro
	$Fond.hide()                                        # cache le fond du menu pause
	$"VBoxContainer/Menu Button".hide()                               # cache le bouton Menu
	$"VBoxContainer/Restart Button".hide()                            # cache le bouton Restart
	$"Back Button".hide()                               # cache le bouton Retour
	$"Pause Button".show()                              # ré-affiche le bouton Pause
	get_tree().paused = false                           # reprend le jeu avant de relancer la scène
	Global.last_checkpoint_position = Vector2.ZERO     # efface le dernier checkpoint en mémoire vive
	var current_scene = get_tree().current_scene        # récupère la scène courante (non utilisée directement, conservation de référence)
	get_tree().reload_current_scene()                   # recharge le niveau depuis le début (équivalent à relancer la scène)
	print("RESTART")                                    # confirme le restart dans la console de débogage
	Global.last_checkpoint_position = Vector2.ZERO     # double réinitialisation pour s'assurer que la valeur est bien à zéro


# --- MISE À JOUR DES PIÈCES OBJECTIF ---
#piece objectif
func update_piece_objectif_ui():
	for i in range(5):                                                    # parcourt les 5 pièces objectif (indices 0 à 4)
		var key := "piece_objectif_%d" % (i + 1)                          # construit la clé de la pièce (ex: "piece_objectif_1", "piece_objectif_2"...)
		var done := Global.is_piece_objectif_collected(level_id, key)     # vérifie dans Global si cette pièce a été collectée pour ce niveau

		# Exemple visuel :
		# done -> icône pleine / sinon grisée
		icons[i].texture = tex_full if done else tex_empty  # applique la texture pleine si collectée, la texture vide sinon
