extends Area2D

# ─────────────────────────────────────────────────────────────────────────────
# KEY BLOC — Destination de la clé (le cadenas à déverrouiller)
# Le joueur arrive avec la clé → le bloc vibre 1.5s → la pièce objectif
# apparaît au-dessus.
# ─────────────────────────────────────────────────────────────────────────────

# Glisse la scène piece_objectif.tscn ici dans l'Inspector
@export var piece_scene: PackedScene

# Identifiants de la pièce objectif à faire apparaître (doivent correspondre au niveau)
@export var level_id: String = "Lvl_1_1"
@export var piece_objectif_id: String = "piece_objectif_5"

# Hauteur au-dessus du bloc où la pièce apparaît (en pixels)
const SPAWN_OFFSET_Y := -32.0

# Paramètres de la vibration
const SHAKE_STRENGTH := 3.0    # Amplitude de la vibration en pixels
const SHAKE_LOOPS := 12        # Nombre d'aller-retours (12 × 0.12s ≈ 1.5s)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage"):  # Ce n'est pas le joueur
		return

	if not Global.has_key:  # Le joueur n'a pas la clé
		return

	# ── Le joueur arrive avec la clé ─────────────────────────────────────────
	Global.has_key = false

	# Désactive la collision pour ne pas déclencher deux fois
	$CollisionShape2D.set_deferred("disabled", true)

	# Supprime la clé qui suivait le joueur
	var key_node = get_tree().get_first_node_in_group("key")
	if key_node:
		key_node.queue_free()

	# Lance la séquence : vibration puis apparition de la pièce
	_vibrer_puis_spawner()


func _vibrer_puis_spawner() -> void:
	var sprite := $Sprite2D

	# Vibration : aller-retour gauche/droite SHAKE_LOOPS fois
	var tween = create_tween()
	tween.set_loops(SHAKE_LOOPS)                                           # Répète N fois
	tween.tween_property(sprite, "position", Vector2(SHAKE_STRENGTH, 0), 0.06)   # Va à droite
	tween.tween_property(sprite, "position", Vector2(-SHAKE_STRENGTH, 0), 0.06)  # Va à gauche

	await tween.finished                   # Attend la fin de toute la vibration

	sprite.position = Vector2.ZERO         # Recentre le sprite après la vibration

	if not piece_scene:
		return

	var piece = piece_scene.instantiate()
	# Assigne les IDs AVANT add_child pour que _ready() → _apply_state_from_save() lise les bonnes valeurs
	piece.level_id = level_id
	piece.piece_objectif_id = piece_objectif_id
	get_tree().current_scene.add_child(piece)

	if Global.is_piece_objectif_collected(level_id, piece_objectif_id):
		# Déjà collectée → apparaît directement à sa position finale avec le sprite "piece recup"
		piece.global_position = global_position + Vector2(0, SPAWN_OFFSET_Y)
	else:
		# Pas encore collectée → animation de sortie du bloc
		piece.global_position = global_position
		piece.modulate.a = 0.0
		piece.scale = Vector2(0.3, 0.3)

		var appear_tween = piece.create_tween()
		appear_tween.set_parallel(true)                                              # Toutes les propriétés en même temps
		appear_tween.tween_property(piece, "global_position",
			global_position + Vector2(0, SPAWN_OFFSET_Y), 0.5)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)            # Monte avec léger dépassement
		appear_tween.tween_property(piece, "modulate:a", 1.0, 0.4)           # Fade in
		appear_tween.tween_property(piece, "scale", Vector2(1.0, 1.0), 0.4)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)            # Grossit avec léger dépassement
