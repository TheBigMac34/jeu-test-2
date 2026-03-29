extends Area2D

# ─────────────────────────────────────────────────────────────────────────────
# KEY — Clé à ramasser dans le niveau (style Mario)
# Le joueur la touche → elle le suit jusqu'au key_bloc.
# Quand le joueur prend un dégât → elle reste à sa position et flotte.
# ─────────────────────────────────────────────────────────────────────────────

# Suivi du joueur
const OFFSET := Vector2(18, -8)        # Décalage derrière le joueur
const LERP_SPEED := 10.0               # Vitesse de suivi (plus grand = plus collé)

# Animation de flottement
const FLOAT_AMPLITUDE := 3.0           # Amplitude du mouvement haut/bas (pixels)
const FLOAT_SPEED := 2.5               # Vitesse du cycle de flottement

var is_carried := false                # true quand le joueur porte la clé
var player_ref : Node2D = null         # Référence au joueur pour le suivi

var float_origin_y := 0.0             # Position Y de référence pour le flottement
var float_time := 0.0                  # Compteur de temps pour l'animation sin()


func _ready() -> void:
	add_to_group("key")                # Permet au key_bloc de retrouver la clé facilement
	body_entered.connect(_on_body_entered)
	float_origin_y = global_position.y # Position initiale = référence du flottement


func _process(delta: float) -> void:
	# ── Mode suivi du joueur ──────────────────────────────────────────────────
	if is_carried:
		if not is_instance_valid(player_ref):
			return
		# Calcule la position cible à côté du joueur (se retourne selon sa direction)
		var dir: float = sign(player_ref.scale.x) if player_ref.scale.x != 0 else 1.0
		var target := player_ref.global_position + Vector2(-OFFSET.x * dir, OFFSET.y)
		# Lerp : la clé glisse vers la cible progressivement
		global_position = global_position.lerp(target, LERP_SPEED * delta).round()
		return

	# ── Mode flottement (posée ou jamais ramassée) ────────────────────────────
	float_time += delta
	# Mouvement sinusoïdal haut/bas autour de la position de référence
	global_position.y = float_origin_y + sin(float_time * FLOAT_SPEED) * FLOAT_AMPLITUDE


func _on_body_entered(body: Node2D) -> void:
	if is_carried:
		return  # Déjà portée, on ignore

	if body.has_method("take_damage"):  # C'est le joueur
		is_carried = true
		player_ref = body
		Global.has_key = true           # Le joueur porte la clé

		# Désactive la collision pour ne plus re-ramasser la clé
		$CollisionShape2D.set_deferred("disabled", true)


func drop() -> void:
	# Appelé quand le joueur prend un dégât — la clé reste sur place et redevient ramassable
	is_carried = false
	player_ref = null
	Global.has_key = false             # Le joueur ne porte plus la clé
	float_origin_y = global_position.y # Flotte à partir de la position où elle a été lâchée

	# Réactive la collision pour que le joueur puisse la reprendre
	$CollisionShape2D.set_deferred("disabled", false)
