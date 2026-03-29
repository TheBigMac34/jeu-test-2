extends CharacterBody2D

# ─────────────────────────────────────────────────────────────────────────────
# CHENILLE 4 — Surface Walker
# Approche : suivi mathématique du périmètre de la plateforme.
# Pas de gravité, pas de raycast, pas de is_on_floor().
# La chenille avance d'un certain nombre de pixels par seconde sur le périmètre
# et sa position est recalculée chaque frame par trigonométrie pure.
# ─────────────────────────────────────────────────────────────────────────────

# Vitesse en pixels/s le long du périmètre.
# Positif = sens horaire (dessus→droite→dessous→gauche)
# Négatif = sens antihoraire
@export var speed := -40.0

# Position de départ sur le périmètre (0.0 = coin haut-gauche, 0.5 = milieu du dessus)
# Permet de décaler chaque chenille pour qu'elles ne soient pas toutes au même endroit
@export_range(0.0, 1.0) var start_progress_ratio := 0.5

# Décalage centre du perso ↔ bord de la plateforme selon la surface.
# Les tiles Kenney ne sont pas parfaitement centrés sur la collision shape,
# donc le dessus et le dessous ont des valeurs légèrement différentes.
@export var offset_top    := 14.0   # Dessus   (normal UP)
@export var offset_bottom := 13.0   # Dessous  (normal DOWN)
@export var offset_side   := 14.0   # Côtés    (normal LEFT / RIGHT)

# Position courante sur le périmètre en pixels (0 = coin haut-gauche, croît CW)
var perimeter_progress := 0.0
var perimeter_total := 0.0   # Longueur totale du périmètre
var platform_rect := Rect2() # Bords de la plateforme en espace local du Node2D parent

var on_screen := true  # Actif par défaut ; le notifier peut le désactiver hors écran si le signal est connecté

@onready var sprite         = $AnimatedSprite2D
@onready var col_shape_self = $CollisionShape2D  # CollisionShape de la chenille (pas celle du StaticBody2D)
@onready var area           = $Area2D


# ─── INITIALISATION ──────────────────────────────────────────────────────────
func _ready() -> void:
	# Récupère la taille et la position de la plateforme depuis son CollisionShape2D
	var col_shape = get_node("StaticBody2D/CollisionShape2D")  # Le StaticBody2D est maintenant un enfant direct
	var shape_size: Vector2 = col_shape.shape.size          # ex: Vector2(67, 15)
	var shape_center: Vector2 = col_shape.position          # ex: Vector2(33.5, 7.5)

	# Rect de la plateforme dans l'espace local du parent (coin haut-gauche → coin bas-droit)
	platform_rect = Rect2(shape_center - shape_size / 2.0, shape_size)

	# Périmètre total = 2 × (largeur + hauteur)
	perimeter_total = 2.0 * (shape_size.x + shape_size.y)

	# Démarre à la position définie par start_progress_ratio (0.5 = milieu du dessus)
	perimeter_progress = perimeter_total * start_progress_ratio

	velocity = Vector2.ZERO  # Pas de déplacement physique


# ─── PHYSIQUE (appelé chaque frame) ──────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if not on_screen:
		return

	# Avance sur le périmètre et boucle proprement
	perimeter_progress = fposmod(perimeter_progress + speed * delta, perimeter_total)

	# Calcule le point sur la surface et la normale à cette position
	var data := _get_surface_data(perimeter_progress)
	var surface_point: Vector2 = data[0]   # Point sur le bord de la plateforme
	var surface_normal: Vector2 = data[1]  # Direction "vers l'extérieur" de la surface

	# Calcule la position locale (dans l'espace de la racine) où la chenille doit être
	# On ne déplace PAS la racine (ça bougerait aussi la plateforme !),
	# on déplace uniquement les enfants sprite, collision et area.
	var offset := _get_offset(surface_normal)
	var local_pos := surface_point + surface_normal * offset
	sprite.position         = local_pos
	col_shape_self.position = local_pos
	area.position           = local_pos

	# Met à jour la rotation et l'orientation du sprite
	_update_sprite(surface_normal)


# ─── OFFSET SELON LA SURFACE ─────────────────────────────────────────────────
# Retourne le bon décalage selon la normale de la surface
func _get_offset(normal: Vector2) -> float:
	if normal == Vector2.UP:
		return offset_top
	elif normal == Vector2.DOWN:
		return offset_bottom
	else:
		return offset_side


# ─── CALCUL DE POSITION SUR LE PÉRIMÈTRE ─────────────────────────────────────
# Entrée : t = distance en pixels depuis le coin haut-gauche (sens horaire)
# Sortie  : [point sur le bord, normale sortante]
func _get_surface_data(t: float) -> Array:
	var w := platform_rect.size.x     # Largeur
	var h := platform_rect.size.y     # Hauteur
	var tl := platform_rect.position  # Coin haut-gauche

	if t < w:
		# ── DESSUS : de gauche à droite ──────────────────────────────────────
		return [tl + Vector2(t, 0), Vector2.UP]

	elif t < w + h:
		# ── MUR DROIT : de haut en bas ───────────────────────────────────────
		return [tl + Vector2(w, t - w), Vector2.RIGHT]

	elif t < 2.0 * w + h:
		# ── DESSOUS : de droite à gauche ─────────────────────────────────────
		return [tl + Vector2(w - (t - w - h), h), Vector2.DOWN]

	else:
		# ── MUR GAUCHE : de bas en haut ──────────────────────────────────────
		return [tl + Vector2(0, h - (t - 2.0 * w - h)), Vector2.LEFT]


# ─── MISE À JOUR DU SPRITE ───────────────────────────────────────────────────
func _update_sprite(surface_normal: Vector2) -> void:
	# Rotation : le sprite tourne pour "coller" à la surface
	# surface_normal.angle() + PI/2 aligne le "haut" du sprite avec la normale
	# On remet la rotation à 0 d'abord pour éviter l'accumulation
	sprite.rotation = surface_normal.angle() + PI / 2.0

	# Flip horizontal : le sprite regarde par défaut à GAUCHE (d'après l'image)
	# flip_h = false → regarde dans la direction CCW (antihoraire)
	# flip_h = true  → regarde dans la direction CW (horaire)
	# Donc on flippe seulement si on va dans le sens horaire
	var going_cw := speed > 0
	sprite.flip_h = going_cw


# ─── DÉGÂTS AU JOUEUR ────────────────────────────────────────────────────────
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  # Le corps peut-il recevoir des dégâts ?
		body.take_damage()              # Inflige des dégâts au joueur


# ─── ACTIVATION À L'ÉCRAN ────────────────────────────────────────────────────
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true  # Active la chenille dès qu'elle est visible
