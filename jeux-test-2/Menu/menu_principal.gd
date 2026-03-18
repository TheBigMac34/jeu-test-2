extends Control

# --- PRÉCHARGEMENT DES SCÈNES ---
@onready var first_level = preload("res://lvl 1/lvl_1_1.tscn")   # précharge la scène du niveau 1-1 pour un chargement rapide
@onready var second_level = preload("res://lvl 1/lvl_1_2.tscn")  # précharge la scène du niveau 1-2

# --- RÉFÉRENCES AUX SPRITES DE MÉDAILLES ---
@onready var bronze_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/Bronze 1-1"    # sprite affichant la médaille bronze du niveau 1-1
@onready var argent_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/argent1-1"     # sprite affichant la médaille argent du niveau 1-1
@onready var gold_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/or 1-1"          # sprite affichant la médaille or du niveau 1-1

# --- VARIABLES ---
var save_path = "user://savegame.json"  # chemin local vers le fichier de sauvegarde principal


# --- INITIALISATION DU FICHIER DE SAUVEGARDE ---
func init_save_if_needed():
	if not FileAccess.file_exists(save_path):              # vérifie si un fichier de sauvegarde existe déjà
		print("Création de la sauvegarde par défaut")      # indique dans la console qu'on crée une sauvegarde neuve
		var default_data := {                              # définit la structure par défaut de la sauvegarde
		"level_1_1_done": false,                           # niveau 1-1 non complété par défaut
		"level_1_1_silver": false,                         # médaille argent non obtenue par défaut
		"level_1_1_gold": false,                           # médaille or non obtenue par défaut
		"piece_objectif": {                                # structure des pièces objectif par niveau
			"Lvl_1_1": {                                   # sous-dictionnaire pour le niveau 1-1
				"piece_objectif_1": false,                 # pièce 1 non collectée par défaut
				"piece_objectif_2": false,                 # pièce 2 non collectée par défaut
				"piece_objectif_3": false,                 # pièce 3 non collectée par défaut
				"piece_objectif_4": false,                 # pièce 4 non collectée par défaut
				"piece_objectif_5": false                  # pièce 5 non collectée par défaut
			}
		}
	}
		var file := FileAccess.open(Global.save_path, FileAccess.WRITE) # ouvre le fichier de sauvegarde en écriture
		if file:                                                         # vérifie que l'ouverture a réussi
			file.store_string(JSON.stringify(default_data))              # écrit les données par défaut au format JSON
			file.close()                                                 # ferme le fichier pour valider l'écriture


# --- MÉDAILLES : AFFICHAGE PAR DÉFAUT (pointillés) ---
func apply_default_medals():
	bronze_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png") # affiche l'icône vide (pointillés) pour la médaille bronze
	argent_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png") # affiche l'icône vide (pointillés) pour la médaille argent
	gold_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png")   # affiche l'icône vide (pointillés) pour la médaille or


# --- LECTURE DE LA SAUVEGARDE ---
func load_save():
	if FileAccess.file_exists(save_path):                          # vérifie si le fichier de sauvegarde existe
		var file = FileAccess.open(save_path, FileAccess.READ)     # ouvre le fichier en lecture
		return JSON.parse_string(file.get_as_text())               # lit et désérialise le contenu JSON, retourne le dictionnaire
	return {}                                                      # retourne un dictionnaire vide si pas de sauvegarde

func save_game(data):
	var file = FileAccess.open(save_path, FileAccess.WRITE) # ouvre le fichier de sauvegarde en écriture
	file.store_string(JSON.stringify(data))                  # écrit les données passées en paramètre au format JSON


# --- MÉDAILLES : RÉCOMPENSES VISUELLES ---
func apply_bronze_reward():
	bronze_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076.png") # remplace l'icône pointillés par la vraie médaille bronze

func apply_silver_reward():
	argent_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0077.png") # remplace l'icône pointillés par la vraie médaille argent

func apply_gold_reward() :
	gold_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0078.png")   # remplace l'icône pointillés par la vraie médaille or


# --- INITIALISATION DU MENU ---
func _ready() -> void:
	init_save_if_needed()  # crée le fichier de sauvegarde s'il n'existe pas encore

	$"Level 1/VBoxContainer/Level 1-1".update_visual()   # met à jour la couleur du bouton 1-1 selon les médailles sauvegardées
	#$"Level 1/VBoxContainer/Level 1-2".update_visual()
	#$"Level 1/VBoxContainer/Level 1-3".update_visual()
	$"Main Menu Music".play()               # lance la musique du menu principal
	$Reset.hide()                           # cache le bouton Reset (visible seulement dans la sélection de niveau)
	$"Chose your level".show()              # affiche le bouton de sélection de niveau sur l'écran principal
	$"Main Menu".show()                     # affiche le panneau du menu principal
	$back.hide()                            # cache le bouton Retour (visible seulement en sélection de niveau)
	$"Level 1".hide()                       # cache le conteneur des niveaux du monde 1
	$"Level 1/VBoxContainer".hide()         # cache la liste déroulante des niveaux du monde 1
	# --- NAVIGATION MANETTE : activation du focus sur tous les boutons ---
	# Certains boutons n'ont pas de script qui active focus_mode, on le force ici
	$Quit.focus_mode = Control.FOCUS_ALL
	$Reset.focus_mode = Control.FOCUS_ALL
	$"Level 1/VBoxContainer/Level 1-1".focus_mode = Control.FOCUS_ALL
	$"Level 1/VBoxContainer/Level 1-2".focus_mode = Control.FOCUS_ALL
	$"Level 1/VBoxContainer/Level 1-3".focus_mode = Control.FOCUS_ALL

	# --- NAVIGATION MANETTE : définition manuelle des voisins de focus ---
	# Sans ça, Godot ne sait pas dans quel ordre aller car les boutons sont éparpillés sur l'écran

	# Menu principal : Chose your level ↕ Quit
	$"Chose your level".focus_neighbor_bottom = $"Chose your level".get_path_to($Quit)
	$Quit.focus_neighbor_top = $Quit.get_path_to($"Chose your level")

	# Sélection de niveau : back → Level 1 → Level 1-1 → Level 1-2 → Level 1-3 → Reset
	var lvl1  = $"Level 1"
	var lvl11 = $"Level 1/VBoxContainer/Level 1-1"
	var lvl12 = $"Level 1/VBoxContainer/Level 1-2"
	var lvl13 = $"Level 1/VBoxContainer/Level 1-3"

	$back.focus_neighbor_bottom      = $back.get_path_to(lvl1)
	$back.focus_neighbor_right       = $back.get_path_to(lvl11)

	lvl1.focus_neighbor_top          = lvl1.get_path_to($back)
	lvl1.focus_neighbor_bottom       = lvl1.get_path_to(lvl11)
	lvl1.focus_neighbor_right        = lvl1.get_path_to(lvl11)

	lvl11.focus_neighbor_top         = lvl11.get_path_to(lvl1)
	lvl11.focus_neighbor_bottom      = lvl11.get_path_to(lvl12)
	lvl11.focus_neighbor_left        = lvl11.get_path_to(lvl1)

	lvl12.focus_neighbor_top         = lvl12.get_path_to(lvl11)
	lvl12.focus_neighbor_bottom      = lvl12.get_path_to(lvl13)

	lvl13.focus_neighbor_top         = lvl13.get_path_to(lvl12)
	lvl13.focus_neighbor_bottom      = lvl13.get_path_to($Reset)

	$Reset.focus_neighbor_top        = $Reset.get_path_to(lvl13)

	$"Chose your level".grab_focus()        # donne le focus au premier bouton pour permettre la navigation manette
	var data = load_save()                  # charge les données de sauvegarde pour afficher les médailles
	apply_default_medals()                  # reset une fois : met toutes les médailles en pointillés
	if data.get("level_1_1_done", false):   # si le niveau 1-1 a été complété au moins une fois
		apply_bronze_reward()               # affiche la médaille bronze
	if data.get("level_1_1_silver", false): # si la médaille argent a été obtenue sur le niveau 1-1
		apply_silver_reward()               # affiche la médaille argent
	if data.get("level_1_1_gold", false):   # si la médaille or a été obtenue sur le niveau 1-1
		apply_gold_reward()                 # affiche la médaille or


# --- BOUTON : SÉLECTION DE NIVEAU ---
func _on_chose_your_level_pressed() -> void:
	$"Level 1/VBoxContainer/Level 1-1".update_visual() # rafraîchit la couleur du bouton selon la sauvegarde actuelle
	#print("test")
	$Reset.show()              # affiche le bouton de réinitialisation de la sauvegarde
	$"Chose your level".hide() # cache le bouton de sélection du menu principal
	$"Main Menu".hide()        # cache le titre du menu principal
	$back.show()               # affiche le bouton Retour vers le menu
	$"Level 1".show()          # affiche le conteneur du monde 1
	$Quit.hide()               # cache le bouton Quitter pendant la navigation dans les niveaux
	$"Level 1".grab_focus()    # donne le focus au bouton "Monde 1" pour la navigation manette


# --- BOUTON : RETOUR AU MENU PRINCIPAL ---
func _on_back_pressed() -> void:
	$"Level 1/VBoxContainer/Level 1-1".update_visual() # rafraîchit la couleur du bouton avant de revenir au menu
	$Reset.hide()               # cache le bouton Reset
	$"Chose your level".show()  # ré-affiche le bouton de sélection de niveau
	$"Main Menu".show()         # ré-affiche le titre du menu principal
	$back.hide()                # cache le bouton Retour
	$"Level 1".hide()           # cache le conteneur des niveaux du monde 1
	$"Level 1/VBoxContainer".hide() # cache la liste des niveaux
	$Quit.show()                # ré-affiche le bouton Quitter
	$"Chose your level".grab_focus() # remet le focus sur le premier bouton en revenant au menu


# --- BOUTON : MONDE 1 (déplie la liste des niveaux) ---
func _on_level_1_pressed() -> void:
	Global.clear_checkpoint()                          # supprime tout checkpoint sauvegardé pour repartir proprement
	var box = $"Level 1/VBoxContainer"                 # récupère le conteneur qui liste les niveaux du monde 1
	box.visible = not box.visible                      # bascule la visibilité : affiche ou cache la liste des niveaux
	Global.vies_actuelles = 3                          # remet les vies au maximum quand on accède au monde 1
	#print("niveau 1")
	$"Level 1/VBoxContainer/Level 1-1".update_visual() # rafraîchit la couleur du bouton 1-1
	if box.visible:
		$"Level 1/VBoxContainer/Level 1-1".grab_focus() # donne le focus au premier niveau quand la liste s'ouvre


# --- BOUTON : LANCER LE NIVEAU 1-1 ---
func _on_level_11_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)               # charge et lance la scène du niveau 1-1
	Global.dernier_niveau_path = "res://lvl 1/lvl_1_1.tscn"     # mémorise le chemin du niveau pour pouvoir le relancer
	Global.coins = 0                                             # remet le compteur de pièces à zéro pour ce niveau


# --- BOUTON : LANCER LE NIVEAU 1-2 ---
func _on_level_12_pressed() -> void:
	get_tree().change_scene_to_packed(second_level)              # charge et lance la scène du niveau 1-2
	Global.dernier_niveau_path = "res://lvl 1/lvl_1_2.tscn"     # mémorise le chemin du niveau pour pouvoir le relancer
	Global.coins = 0                                             # remet le compteur de pièces à zéro pour ce niveau


# --- BOUTON : QUITTER LE JEU ---
func _on_quit_pressed() -> void:
	get_tree().quit()  # ferme l'application proprement


# --- BOUTON : RÉINITIALISER LA SAUVEGARDE ---
func _on_reset_pressed() -> void:
	var default_data = {                      # construit le dictionnaire de sauvegarde par défaut à écrire
		"has_dash": false,                    # réinitialise le power-up dash à non débloqué
		"has_double_jump":false,              # réinitialise le power-up double saut à non débloqué
		"level_1_1_done": false,              # réinitialise la progression du niveau 1-1
		"level_1_1_silver": false,            # réinitialise la médaille argent du niveau 1-1
		"level_1_1_gold": false,              # réinitialise la médaille or du niveau 1-1
		"piece_objectif": {                   # réinitialise toutes les pièces objectif
			"Lvl_1_1": {                      # sous-dictionnaire pour le niveau 1-1
				"piece_objectif_1": false,    # remet la pièce 1 à non collectée
				"piece_objectif_2": false,    # remet la pièce 2 à non collectée
				"piece_objectif_3": false,    # remet la pièce 3 à non collectée
				"piece_objectif_4": false,    # remet la pièce 4 à non collectée
				"piece_objectif_5": false     # remet la pièce 5 à non collectée
			}
		}
	}
	$"Level 1/VBoxContainer/Level 1-1".update_visual()          # rafraîchit la couleur du bouton (repassera en blanc)
	var file = FileAccess.open(save_path, FileAccess.WRITE)      # ouvre le fichier de sauvegarde en écriture
	file.store_string(JSON.stringify(default_data))              # écrase le fichier avec les données par défaut
	file.close()                                                 # ferme le fichier pour valider l'écriture
	Global.data = default_data                                   # synchronise le dictionnaire global avec les données réinitialisées
	Global.piece_objectif = default_data["piece_objectif"]       # synchronise les pièces objectif dans le singleton Global
	Global.has_dash = false          # ← ajoute ça : réinitialise le dash en mémoire vive
	Global.has_double_jump = false   # ← et ça : réinitialise le double saut en mémoire vive
	# Recharge l'UI si elle est ailleurs
	get_tree().call_group("hud", "refresh_ui") # notifie tous les noeuds du groupe "hud" de se rafraîchir

	apply_default_medals()   # remet toutes les médailles en icônes pointillés (état vide)
	print("Reset")           # confirme le reset dans la console de débogage
