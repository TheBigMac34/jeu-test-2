extends Node2D

# --- CONFIGURATION EXPORTÉE ---
# "dash" pour lvl 1_2 (orbe rouge), "double_saut" pour lvl 1_3 (orbe bleue)
@export var type_orbe: String = "dash"  # détermine quel power-up le PNJ donne : "dash" ou "double_saut"

# --- RÉFÉRENCES AUX NOEUDS ---
@onready var animation_pnj  = $AnimatedSprite2D                       # sprite animé du PNJ (animation idle, parle, etc.)
@onready var dialogue_panel = $DialogueBulle/DialoguePanel             # panneau contenant la bulle de dialogue
@onready var label_texte    = $DialogueBulle/DialoguePanel/RichTextLabel # label affichant le texte du dialogue (effet machine à écrire)
@onready var label_hint     = $DialogueBulle/DialoguePanel/HintLabel   # label affichant l'indication de touche à appuyer
@onready var orbe_node      = $Orbe                                    # noeud parent de l'orbe (rendu visible lors de la remise)
@onready var orbe_sprite    = $Orbe/Sprite2D                           # sprite de l'orbe, dont la texture sera dupliquée pour l'animation

# --- VARIABLES D'ÉTAT ---
var player_ref: Node2D = null      # référence au joueur entré dans la zone (null si personne)
var interaction_done := false      # vrai si le joueur a déjà reçu le pouvoir (empêche de rejouer la séquence)
var en_attente_touche := false     # vrai quand le jeu attend que le joueur appuie sur A pour continuer le dialogue

# --- SIGNAL ---
signal touche_appuyee  # émis quand le joueur appuie sur la touche d'acceptation pendant l'attente du dialogue

# --- TEXTES DE DIALOGUE PAR TYPE D'ORBE ---
const TEXTES = {
	"dash":
		"Ah, un voyageur !\nJe t'attendais...\n\nPrens cette orbe rouge.\nElle te permettra\nde foncer comme l'éclair !",  # dialogue du PNJ pour l'orbe dash
	"double_saut":
		"Te revoilà ! Tu as bien avancé.\n\nPrens cette orbe bleue.\nElle te donnera la force\nde sauter deux fois\ndans les airs !"  # dialogue du PNJ pour l'orbe double saut
}


# --- INITIALISATION ---
func _ready() -> void:
	dialogue_panel.visible = false   # cache la bulle de dialogue au démarrage
	orbe_node.visible = false        # cache l'orbe au démarrage (elle n'apparaît que lors de la remise)
	# Si le joueur a déjà ce pouvoir, l'interaction ne se déclenchera pas
	if type_orbe == "dash" and Global.has_dash:          # vérifie si le power-up dash est déjà débloqué dans la save
		interaction_done = true                          # marque l'interaction comme terminée pour ne pas la rejouer
	elif type_orbe == "double_saut" and Global.has_double_jump: # vérifie si le double saut est déjà débloqué dans la save
		interaction_done = true                          # marque l'interaction comme terminée


# --- TRAITEMENT CHAQUE FRAME ---
func _process(_delta: float) -> void:
	# Écoute l'appui sur Entrée pour avancer dans le dialogue
	if en_attente_touche and Input.is_action_just_pressed("ui_accept"): # vérifie si on attend une touche ET que le joueur vient d'appuyer sur A
		en_attente_touche = false  # désactive l'attente pour ne pas capturer plusieurs fois le même appui
		touche_appuyee.emit()      # émet le signal pour débloquer le await dans _demarrer_sequence()


# --- DÉCLENCHEUR DE ZONE ---
func _on_zone_body_entered(body: Node2D) -> void:
	if body.name != "Player" or interaction_done: # ignore les corps qui ne sont pas le joueur, et bloque si déjà interagi
		return                                     # arrête la fonction si la condition n'est pas remplie
	player_ref = body                              # mémorise la référence au joueur pour pouvoir le figer et le défiger
	player_ref.figer()                             # fige le joueur (bloque ses inputs, maintient la gravité)
	_demarrer_sequence()                           # lance la séquence de dialogue et de remise d'orbe
	animation_pnj.play("idle")                     # démarre l'animation idle du PNJ pendant la séquence


# --- SÉQUENCE PRINCIPALE DE DIALOGUE ET REMISE D'ORBE ---
func _demarrer_sequence() -> void:
	await get_tree().create_timer(0.4).timeout  # attend 0.4 seconde avant d'afficher le dialogue (délai naturel)

	var texte: String = TEXTES.get(type_orbe, "...")  # récupère le texte correspondant au type d'orbe, "..." si inconnu
	dialogue_panel.visible = true                      # rend la bulle de dialogue visible
	label_hint.visible = false                         # cache l'indication de touche au début (apparaît à la fin du texte)

	label_texte.visible_characters = 0  # met visible_characters à 0 AVANT de changer le texte → empêche le flash du texte complet
	label_texte.text = texte            # assigne le texte au label (layout calculé, mais rien n'est encore visible)
	await get_tree().process_frame      # attend une frame pour que le layout soit stable avant d'animer

	var nb_chars := texte.length()      # récupère le nombre total de caractères du texte pour savoir combien d'étapes animer
	for i in range(nb_chars):           # boucle sur chaque caractère du texte
		label_texte.visible_characters = i + 1             # révèle les caractères un par un (effet machine à écrire)
		await get_tree().create_timer(0.03).timeout        # attend 30ms entre chaque caractère pour le rythme de frappe

	# Inviter le joueur à appuyer
	label_hint.text = "[ Appuie sur A ]" # affiche l'indication de touche une fois le texte entièrement affiché
	label_hint.visible = true             # rend visible l'indication de touche
	en_attente_touche = true              # active l'écoute de la touche dans _process()
	await touche_appuyee                  # suspend la séquence jusqu'à ce que le joueur appuie sur A

	# Montrer l'orbe
	dialogue_panel.visible = false        # cache la bulle de dialogue après l'appui du joueur
	orbe_node.visible = true              # affiche l'orbe flottante pour la remise visuelle
	await get_tree().create_timer(2.0).timeout # attend 2 secondes pour laisser le joueur voir l'orbe
	orbe_node.visible = false             # cache l'orbe avant de lancer l'animation d'absorption
	await _explosion_absorption()         # joue l'animation d'explosion et d'absorption de l'orbe vers le joueur

	# Débloquer le pouvoir et sauvegarder
	if type_orbe == "dash":               # vérifie si l'orbe donnée est l'orbe dash
		Global.has_dash = true            # active le power-up dash dans le singleton Global
	else:
		Global.has_double_jump = true     # sinon, active le power-up double saut dans le singleton Global
	Global.save_game()                    # sauvegarde immédiatement pour persister le pouvoir débloqué

	interaction_done = true               # marque l'interaction comme terminée pour ne pas la rejouer
	if is_instance_valid(player_ref):     # vérifie que le joueur est toujours valide (n'a pas été détruit)
		player_ref.defiger()              # redonne le contrôle au joueur en le défigeant


# --- ANIMATION D'EXPLOSION ET D'ABSORPTION DE L'ORBE ---
func _explosion_absorption() -> void:
	var nb := 5                                                                  # nombre de mini-sprites créés pour l'effet d'explosion
	var origine: Vector2 = orbe_node.global_position                            # position d'origine de l'orbe en coordonnées monde
	var cible: Vector2 = player_ref.global_position if is_instance_valid(player_ref) else origine # position cible : le joueur si valide, sinon l'origine

	for i in range(nb):                          # crée nb mini-sprites pour simuler l'effet de particules
		var mini := Sprite2D.new()               # crée un nouveau Sprite2D dynamiquement
		mini.texture = orbe_sprite.texture       # lui assigne la même texture que l'orbe originale
		mini.scale   = Vector2(0.5, 0.5)         # réduit le sprite à la moitié de sa taille originale
		mini.global_position = origine           # le place à la position de l'orbe au départ
		get_tree().current_scene.add_child(mini) # l'ajoute à la scène courante (pas en enfant du PNJ) pour des coordonnées monde correctes

		# Direction en étoile, légèrement aléatoire
		var angle := (TAU / nb) * i + randf_range(-0.15, 0.15)          # calcule un angle régulier en étoile avec une légère variation aléatoire
		var pos_explosion := origine + Vector2(cos(angle), sin(angle)) * 45.0 # calcule la position d'explosion à 45 pixels de l'origine dans la direction de l'angle

		var t := create_tween()                                          # crée un tween pour animer ce mini-sprite
		# Phase 1 : explosion vers l'extérieur
		# Anime le mini-sprite vers sa position d'explosion en 0.25s, avec courbe cubique sortante (démarre vite, ralentit)
		t.tween_property(mini, "global_position", pos_explosion, 0.25) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t.tween_interval(0.08)                                           # pause de 0.08 secondes entre les deux phases
		# Phase 2 : absorption vers le joueur
		# Anime le mini-sprite vers le joueur en 0.35s, avec courbe cubique entrante (démarre lentement, accélère)
		t.tween_property(mini, "global_position", cible, 0.35) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		# Rétrécit en arrivant
		t.tween_property(mini, "scale", Vector2.ZERO, 0.08)             # réduit le sprite à taille zéro en 0.08 secondes (disparition progressive)
		t.tween_callback(mini.queue_free)                                # supprime le mini-sprite de la mémoire une fois l'animation terminée

	# Attendre la fin de toute l'animation (0.25 + 0.08 + 0.35 + 0.08)
	await get_tree().create_timer(0.76).timeout  # attend 0.76 secondes, durée totale de l'animation d'un mini-sprite
