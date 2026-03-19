extends Node

# --- PRÉCHARGEMENT ---
@onready var over = preload("res://Game Over/Game Over.tscn") # précharge la scène Game Over pour éviter un délai lors du game over

# --- VARIABLES DE SAUVEGARDE ---
var save_path = "user://savegame.json"   # chemin du fichier de sauvegarde principal
var data: Dictionary = {}               # dictionnaire contenant toutes les données de sauvegarde chargées
var piece_objectif := {}                # dictionnaire des pièces objectif collectées par niveau
var levels_data := {}                   # dictionnaire réservé pour les données de niveaux (usage futur)

# --- VARIABLES DE JEU ---
var coins: int = 0                      # nombre de pièces collectées dans la session en cours
var seuil_argent: int = 20             # seuil de pièces à atteindre pour la médaille argent (défini par le niveau)
var vies_max = 3                        # nombre maximum de vies autorisées
var vies_actuelles = 2                  # nombre de vies actuellement disponibles au démarrage
var dernier_niveau_path: String = ""    # chemin de la dernière scène de niveau lancée (pour relancer)
var last_checkpoint_position: Vector2 = Vector2.ZERO # position du dernier checkpoint atteint en mémoire

# --- VARIABLES CHECKPOINT ---
var CHECKPOINT_SAVE := "user://checkpoint.json"       # chemin du fichier de sauvegarde des checkpoints
var checkpoint_position : Vector2 = Vector2.ZERO     # position du checkpoint courant chargé depuis le fichier

# --- MÉDAILLES ---
# Ces booléens sont mis à jour lors de la fin de niveau et lus par fin_niveau.gd
var medaille_bronze: bool = false       # vrai si le niveau a été terminé (médaille bronze obtenue)
var medaille_argent: bool = false       # vrai si 20 pièces ont été collectées (médaille argent obtenue)
var medaille_or: bool = false           # vrai si toutes les pièces objectif ont été collectées (médaille or)
var current_level_scene: String = ""   # chemin de la scène du niveau en cours, utilisé par le bouton Rejouer

# --- POWER-UPS ---
# Ces booléens sont débloqués via interaction avec le PNJ et persistés dans la sauvegarde
var has_dash: bool = false             # vrai si le joueur a débloqué le dash
var has_double_jump: bool = false      # vrai si le joueur a débloqué le double saut


# --- INITIALISATION ---
func _ready():
	print("SAVE FILE PATH:", ProjectSettings.globalize_path(save_path)) # affiche le chemin absolu du fichier de save pour le débogage
	load_game() # charge la sauvegarde existante au démarrage du jeu


# --- SAUVEGARDE ---
func save_game() -> void:
	# IMPORTANT : on met bien piece_objectif dans data avant d'écrire
	data["piece_objectif"] = piece_objectif          # synchronise le sous-dictionnaire des pièces objectif dans data
	data["has_dash"] = has_dash                      # sauvegarde l'état du power-up dash
	data["has_double_jump"] = has_double_jump        # sauvegarde l'état du power-up double saut
	var fw := FileAccess.open(save_path, FileAccess.WRITE) # ouvre le fichier de sauvegarde en écriture
	if fw:                                           # vérifie que l'ouverture a réussi
		fw.store_string(JSON.stringify(data, "\t"))  # écrit le JSON indenté avec des tabulations pour la lisibilité
		fw.close()                                   # ferme le fichier pour valider l'écriture


# --- CHECKPOINTS ---
func save_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos # mémorise la position du checkpoint en mémoire vive

	var file = FileAccess.open(CHECKPOINT_SAVE, FileAccess.WRITE) # ouvre le fichier checkpoint en écriture
	file.store_var(pos) # écrit la position sous forme de Vector2 (format binaire natif Godot)
	file.close() # ferme le fichier pour valider l'écriture

	#print("💾 Checkpoint sauvegardé :", pos)


func load_checkpoint() -> void:
	if not FileAccess.file_exists(CHECKPOINT_SAVE): # vérifie si un fichier checkpoint existe déjà
		#print("❌ Aucun checkpoint sauvegardé")
		checkpoint_position = Vector2.ZERO # réinitialise à zéro si aucun fichier trouvé
		return                             # arrête la fonction ici

	var file = FileAccess.open(CHECKPOINT_SAVE, FileAccess.READ) # ouvre le fichier checkpoint en lecture
	var data = file.get_var()            # lit la variable binaire stockée (devrait être un Vector2)
	file.close()                         # ferme le fichier après lecture

	# 🔐 SÉCURITÉ ANTI-BUG
	if data == null or typeof(data) != TYPE_VECTOR2: # vérifie que la donnée lue est bien un Vector2 valide
		#print("⚠️ Checkpoint invalide, reset")
		checkpoint_position = Vector2.ZERO # réinitialise si la donnée est invalide ou corrompue
		return                             # arrête la fonction ici

	checkpoint_position = data           # applique la position lue comme checkpoint actuel
	#print("📂 Checkpoint chargé :", checkpoint_position)

func clear_checkpoint() -> void:
	checkpoint_position = Vector2.ZERO                         # efface la position checkpoint en mémoire
	if FileAccess.file_exists(CHECKPOINT_SAVE):                # vérifie si le fichier checkpoint existe sur le disque
		DirAccess.remove_absolute(CHECKPOINT_SAVE)             # supprime le fichier checkpoint du disque
		#print("🗑️ Checkpoint supprimé")


# --- SIGNAL SOIN ---
signal heal # signal émis quand le joueur gagne une vie, utilisé pour déclencher des effets visuels

# --- SIGNAL PIÈCE OBJECTIF ---
signal piece_objectif_collected # signal émis quand une pièce objectif est ramassée, pour mettre à jour l'UI


# --- GESTION DES VIES ---
func perdre_vie():
	vies_actuelles -= 1                                              # décrémente le compteur de vies
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)             # s'assure que les vies restent dans l'intervalle [0, vies_max]
	#print("Vies restantes : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")        # cherche le noeud UI dans la scène courante sans planter si absent
	if ui:                                                           # si l'UI existe dans la scène
		ui.update_vie()                                              # met à jour l'affichage des icônes de vie
	if vies_actuelles <= 0:                                          # si le joueur n'a plus de vies
		game_over()                                                  # déclenche la fin de partie


func gagner_vie():
	vies_actuelles += 1                                              # incrémente le compteur de vies
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)             # s'assure de ne pas dépasser vies_max
	#print("Vies actuelles après soin : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")        # cherche le noeud UI dans la scène courante
	if ui:                                                           # si l'UI existe
		ui.update_vie()                                              # met à jour l'affichage des icônes de vie
	emit_signal("heal")                                              # émet le signal heal pour déclencher les effets visuels de soin


# --- CHARGEMENT DE LA SAUVEGARDE ---
#piece objectif
func load_game() -> void:
	if not FileAccess.file_exists(save_path): # vérifie si un fichier de sauvegarde existe
		data = {}                             # initialise data à vide si pas de sauvegarde
		piece_objectif = {}                   # initialise piece_objectif à vide
		return                                # arrête le chargement ici

	var f := FileAccess.open(save_path, FileAccess.READ) # ouvre le fichier de sauvegarde en lecture
	if not f:                                            # vérifie que l'ouverture a réussi
		data = {}                                        # initialise data à vide en cas d'erreur d'ouverture
		piece_objectif = {}                              # initialise piece_objectif à vide
		return                                           # arrête le chargement ici

	var parsed = JSON.parse_string(f.get_as_text())      # lit le contenu du fichier et le désérialise depuis JSON
	f.close()                                            # ferme le fichier après lecture

	if typeof(parsed) != TYPE_DICTIONARY:               # vérifie que le JSON est bien un dictionnaire valide
		data = {}                                        # réinitialise si le format est invalide ou corrompu
		piece_objectif = {}                              # réinitialise piece_objectif
		return                                           # arrête le chargement ici

	data = parsed                                                    # stocke le dictionnaire parsé comme données actives
	piece_objectif = data.get("piece_objectif", {})                  # récupère les pièces objectif, ou {} si absentes
	has_dash = data.get("has_dash", false)                           # récupère l'état du dash, false par défaut
	has_double_jump = data.get("has_double_jump", false)             # récupère l'état du double saut, false par défaut


# --- PIÈCES OBJECTIF ---
func is_piece_objectif_collected(level_id: String, piece_objectif_id: String) -> bool:
	var raw = piece_objectif.get(level_id, {}).get(piece_objectif_id, false) # récupère la valeur brute pour cette pièce objectif

	if raw is bool:                        # si la valeur est déjà un booléen natif
		return raw                         # on le retourne directement
	if raw is String:                      # si la valeur est une chaîne (artefact JSON parfois)
		return raw.to_lower() == "true"    # on la compare à "true" insensible à la casse
	if raw is int:                         # si la valeur est un entier (0 ou 1)
		return raw == 1                    # 1 = collectée, 0 = non collectée
	return false                           # par défaut, la pièce n'est pas collectée


func set_piece_objectif_collected(level_id: String, piece_objectif_id: String) -> void:
	if not piece_objectif.has(level_id):        # vérifie si l'entrée pour ce niveau existe déjà
		piece_objectif[level_id] = {}           # crée l'entrée pour ce niveau si elle est absente
	piece_objectif[level_id][piece_objectif_id] = true # marque cette pièce objectif comme collectée
	save_game()                                 # sauvegarde immédiatement pour persister la progression
	emit_signal("piece_objectif_collected")     # notifie l'UI que l'affichage doit être mis à jour

func get_piece_objectif_count(level_id: String) -> int:
	if not piece_objectif.has(level_id): # vérifie si des données existent pour ce niveau
		return 0                          # retourne 0 si aucune pièce n'a été collectée dans ce niveau
	return piece_objectif[level_id].size() # retourne le nombre de pièces objectif collectées dans ce niveau

func has_all_piece_objectifs(level_id: String, total := 5) -> bool:
	for i in range(1, total + 1):                                                         # parcourt chaque pièce objectif de 1 à total
		if not is_piece_objectif_collected(level_id, "piece_objectif_%d" % i):            # vérifie si la pièce i est collectée
			return false                                                                   # si une pièce manque, retourne false immédiatement
	return true                                                                            # toutes les pièces sont collectées


# --- GAME OVER ---
func game_over():
	#print("GAME OVER !")
	get_tree().change_scene_to_packed(over)                                # charge et affiche la scène Game Over préchargée
	#get_tree().change_scene_to_file("res://game_over.tscn")  # ou autre scène
