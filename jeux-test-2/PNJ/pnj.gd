extends Node2D

# "dash" pour lvl 1_2 (orbe rouge), "double_saut" pour lvl 1_3 (orbe bleue)
@export var type_orbe: String = "dash"

@onready var animation_pnj  = $AnimatedSprite2D
@onready var dialogue_panel = $DialogueBulle/DialoguePanel
@onready var label_texte    = $DialogueBulle/DialoguePanel/RichTextLabel
@onready var label_hint     = $DialogueBulle/DialoguePanel/HintLabel
@onready var orbe_node      = $Orbe
@onready var orbe_sprite    = $Orbe/Sprite2D

var player_ref: Node2D = null
var interaction_done := false
var en_attente_touche := false

signal touche_appuyee

const TEXTES = {
	"dash":
		"Ah, un voyageur !\nJe t'attendais...\n\nPrens cette orbe rouge.\nElle te permettra\nde foncer comme l'éclair !",
	"double_saut":
		"Te revoilà ! Tu as bien avancé.\n\nPrens cette orbe bleue.\nElle te donnera la force\nde sauter deux fois\ndans les airs !"
}

func _ready() -> void:
	dialogue_panel.visible = false
	orbe_node.visible = false
	# Si le joueur a déjà ce pouvoir, l'interaction ne se déclenchera pas
	if type_orbe == "dash" and Global.has_dash:
		interaction_done = true
	elif type_orbe == "double_saut" and Global.has_double_jump:
		interaction_done = true

func _process(_delta: float) -> void:
	# Écoute l'appui sur Entrée pour avancer dans le dialogue
	if en_attente_touche and Input.is_action_just_pressed("ui_accept"):
		en_attente_touche = false
		touche_appuyee.emit()

func _on_zone_body_entered(body: Node2D) -> void:
	if body.name != "Player" or interaction_done:
		return
	player_ref = body
	player_ref.figer()
	_demarrer_sequence()
	animation_pnj.play("idle")

func _demarrer_sequence() -> void:
	await get_tree().create_timer(0.4).timeout

	var texte: String = TEXTES.get(type_orbe, "...")
	dialogue_panel.visible = true
	label_hint.visible = false

	label_texte.visible_characters = 0  # caché AVANT de set le texte → pas de flash
	label_texte.text = texte            # layout calculé, rien affiché
	await get_tree().process_frame      # layout stable

	var nb_chars := texte.length()
	for i in range(nb_chars):
		label_texte.visible_characters = i + 1
		await get_tree().create_timer(0.03).timeout

	# Inviter le joueur à appuyer
	label_hint.text = "[ Appuie sur A ]"
	label_hint.visible = true
	en_attente_touche = true
	await touche_appuyee

	# Montrer l'orbe
	dialogue_panel.visible = false
	orbe_node.visible = true
	await get_tree().create_timer(2.0).timeout
	orbe_node.visible = false
	await _explosion_absorption()

	# Débloquer le pouvoir et sauvegarder
	if type_orbe == "dash":
		Global.has_dash = true
	else:
		Global.has_double_jump = true
	Global.save_game()

	interaction_done = true
	if is_instance_valid(player_ref):
		player_ref.defiger()

func _explosion_absorption() -> void:
	var nb := 5
	var origine: Vector2 = orbe_node.global_position
	var cible: Vector2 = player_ref.global_position if is_instance_valid(player_ref) else origine

	for i in range(nb):
		var mini := Sprite2D.new()
		mini.texture = orbe_sprite.texture
		mini.scale   = Vector2(0.5, 0.5)
		mini.global_position = origine
		get_tree().current_scene.add_child(mini)

		# Direction en étoile, légèrement aléatoire
		var angle := (TAU / nb) * i + randf_range(-0.15, 0.15)
		var pos_explosion := origine + Vector2(cos(angle), sin(angle)) * 45.0

		var t := create_tween()
		# Phase 1 : explosion vers l'extérieur
		t.tween_property(mini, "global_position", pos_explosion, 0.25)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t.tween_interval(0.08)
		# Phase 2 : absorption vers le joueur
		t.tween_property(mini, "global_position", cible, 0.35)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		# Rétrécit en arrivant
		t.tween_property(mini, "scale", Vector2.ZERO, 0.08)
		t.tween_callback(mini.queue_free)

	# Attendre la fin de toute l'animation (0.25 + 0.08 + 0.35 + 0.08)
	await get_tree().create_timer(0.76).timeout
