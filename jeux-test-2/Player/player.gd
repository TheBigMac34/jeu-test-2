extends CharacterBody2D

# --- RÉFÉRENCES AUX NOEUDS ---
@onready var player = $"."                          # Référence au joueur lui-même
@onready var over = preload("res://Game Over/Game Over.tscn")  # Scène Game Over préchargée
@onready var animation = $AnimatedSprite2D          # Sprite animé du joueur
@onready var timer_label = $CanvasLayer/TimerLabel  # Label qui affiche le temps restant
@onready var timer = $CanvasLayer/Timer             # Timer qui décompte chaque seconde

@export var start_position: Vector2                 # Position de départ (non utilisée directement, le spawn se fait via SpawnPoint)

# --- VARIABLES GÉNÉRALES ---
var last_checkpoint: Vector2                        # Position du dernier checkpoint atteint
var time_left := 300                                # Temps restant en secondes (5 minutes)
var invincible = false                              # True quand le joueur est invincible après dégâts
var blink_timer := 2.0                              # Compteur pour l'effet de clignotement
var move_input : float                              # Valeur de l'axe de déplacement gauche/droite
var fige := false                                   # True quand le joueur est bloqué (ex: contact drapeau fin)

# --- DOUBLE SAUT ---
var sauts_restants: int = 1                         # Nombre de sauts encore disponibles (1 normal, 2 si double saut)

# --- DASH ---
var can_dash: bool = true                           # True si le dash est rechargé et utilisable
var is_dashing: bool = false                        # True pendant l'exécution d'un dash
var dash_timer: float = 0.0                         # Compteur de durée du dash en cours
var dash_direction: float = 1.0                     # Direction du dash (1.0 = droite, -1.0 = gauche)
var derniere_direction: float = 1.0                 # Dernière direction regardée (pour dash sans input)
const DASH_DURATION: float = 0.2                    # Durée du dash en secondes
const DASH_SPEED: float = 400.0                     # Vitesse horizontale pendant le dash

# --- TRAIL (effet fantôme pendant le dash) ---
var trail_timer: float = 0.0                        # Compteur pour espacer les fantômes du trail
const TRAIL_INTERVAL: float = 0.05                  # Intervalle entre chaque fantôme (en secondes)

# --- PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur Godot) ---
@export var Y_LIMITE = 100                          # Si le joueur passe sous cette valeur Y, game over (chute dans le vide)
@export var INVINCIBILITY_TIME := 2.0               # Durée d'invincibilité après avoir pris des dégâts
@export var BLINK_INTERVAL := 0.1                   # Vitesse du clignotement pendant l'invincibilité
@export var SPEED = 200                             # Vitesse de déplacement normale
@export var acceleration : float = 50              # Rapidité à atteindre la vitesse max
@export var braking : float = 20                   # Rapidité à s'arrêter quand on lâche la direction
@export var JUMP_VELOCITY = -300                    # Force du saut (négatif = vers le haut)

# --- TIMER DE NIVEAU ---
func _on_timer_timeout() -> void:
	# Appelé chaque seconde par le Timer du CanvasLayer
	time_left -= 1                                  # On enlève 1 seconde
	update_timer_label()                            # On met à jour l'affichage
	if time_left <= 0:
		timer.stop()
		Global.game_over()                          # Temps écoulé = game over
		print("Temps écoulé !")

func update_timer_label():
	# Met à jour le texte affiché du timer
	timer_label.text = str(time_left) + ""

# --- INITIALISATION ---
func _ready() -> void:
	timer.start()                                   # Lance le décompte du niveau
	animation.play("player 1")                      # Animation par défaut au démarrage

	var spawn_point = get_parent().get_node("SpawnPoint")  # Récupère le point de spawn du niveau

	if Global.checkpoint_position != Vector2.ZERO:
		# Si un checkpoint a été sauvegardé, on réapparaît là
		player.global_position = Global.checkpoint_position
		print("🎯 Spawn au checkpoint")
	else:
		# Sinon on réapparaît au début du niveau
		global_position = spawn_point.global_position
		print("Spawn au début du niveau")


# --- BOUCLE PRINCIPALE ---
func _physics_process(delta: float) -> void:

	# Chute dans le vide : si le joueur descend trop bas → game over
	if position.y > Y_LIMITE:
		Global.game_over()

	# Effet de clignotement pendant l'invincibilité
	if invincible:
		blink_timer += delta
		if int(blink_timer / BLINK_INTERVAL) % 2 == 0:
			animation.visible = false               # Frame paire = invisible
		else:
			animation.visible = true                # Frame impaire = visible

	# Gravité appliquée quand le joueur est en l'air
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Si le joueur est figé (ex: touche le drapeau de fin), on freine progressivement et on sort
	if fige:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, braking * delta)  # Freinage progressif
		move_and_slide()
		return                                      # On court-circuite tout le reste

	# --- GESTION DU DASH ---

	# Décompte de la durée du dash
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false                      # Le dash est terminé

	# Recharge du dash dès que le joueur touche le sol
	if not can_dash and not is_dashing and is_on_floor():
		can_dash = true

	# Déclenchement du dash sur appui du bouton (RB Xbox = action "dash")
	if Global.has_dash and can_dash and not is_dashing and Input.is_action_just_pressed("dash"):
		is_dashing = true
		can_dash = false                            # Dash consommé, plus disponible jusqu'au sol
		dash_direction = derniere_direction         # On dashe dans la dernière direction regardée
		dash_timer = DASH_DURATION                  # On lance le timer du dash

	# Pendant le dash : vitesse fixe + effet trail + court-circuit du reste
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED   # Vitesse horizontale du dash
		trail_timer += delta
		if trail_timer >= TRAIL_INTERVAL:
			trail_timer = 0.0
			_spawn_trail_ghost()                    # Crée un fantôme à la position actuelle
		move_and_slide()
		return                                      # On ignore le reste du mouvement pendant le dash

	# --- DOUBLE SAUT ---

	# Réinitialise les sauts disponibles quand on touche le sol
	if is_on_floor():
		sauts_restants = 2 if Global.has_double_jump else 1

	# Saut sur appui (A Xbox / Espace) si des sauts restants
	if Input.is_action_just_pressed("ui_accept") and sauts_restants > 0:
		velocity.y = JUMP_VELOCITY
		$"Jumps Sound".play()
		sauts_restants -= 1                         # On consomme un saut

	# --- DIRECTION ET ANIMATION ---

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction < 0:
		animation.flip_h = false                    # Joueur regarde à gauche
		derniere_direction = -1.0
	elif direction > 0:
		animation.flip_h = true                     # Joueur regarde à droite
		derniere_direction = 1.0

	# Joue l'animation de marche quand une touche directionnelle est enfoncée
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		animation.play("player 1")

	# --- MOUVEMENT HORIZONTAL ---

	move_input = Input.get_axis("ui_left", "ui_right")

	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * SPEED, acceleration * delta)  # Accélération progressive
	else:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)  # Freinage progressif si aucun input
	move_and_slide()

	# --- DÉTECTION DES COLLISIONS (coup de tête sur un bloc) ---
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Si la normale de la collision pointe vers le bas → le joueur a tapé par-dessous
		if collision.get_normal().y > 0.9:
			if collider.has_method("casser"):
				collider.casser()                   # On casse le bloc (ex: bloc doré)

# --- SYSTÈME DE VIE ---

func take_damage():
	# Appelé quand le joueur touche un ennemi ou un danger
	if invincible:
		return                                      # Aucun dégât pendant l'invincibilité
	Global.perdre_vie()
	if Global.vies_actuelles <= 0:
		call_deferred("_go_to_game_over")           # Plus de vies = game over
		return
	var ui = get_tree().current_scene.get_node_or_null("ui")
	if ui:
		ui.update_vie()                             # Met à jour l'affichage des coeurs dans le HUD
	print("outch")
	$"Damage Sond".play()
	invincible = true
	blink_timer = 0.0
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	invincible = false
	animation.visible = true                        # On s'assure que le joueur est visible à la fin

func bounce():
	# Fait rebondir le joueur vers le haut (ex: quand il saute sur un ennemi)
	velocity.y = -400

func figer():
	# Bloque tous les inputs du joueur (appelé par le drapeau de fin)
	fige = true

func defiger():
	# Débloque les inputs du joueur
	fige = false

# --- EFFET TRAIL PENDANT LE DASH ---

func _spawn_trail_ghost() -> void:
	# Récupère la texture de la frame d'animation actuelle du joueur
	var texture = animation.sprite_frames.get_frame_texture(animation.animation, animation.frame)
	if texture == null:
		return                                      # Sécurité si la texture n'est pas disponible

	var ghost = Sprite2D.new()                      # Crée un nouveau sprite "fantôme"
	ghost.texture = texture                         # Lui donne la même apparence que le joueur
	ghost.global_position = global_position         # Placé à la position actuelle du joueur
	ghost.flip_h = animation.flip_h                 # Même orientation (gauche/droite)
	ghost.modulate = Color(0.5, 0.85, 1.0, 0.55)   # Teinte bleutée semi-transparente
	get_parent().add_child(ghost)                   # Ajouté dans la scène (pas en enfant du joueur)

	# Le fantôme s'évapore progressivement sur 0.3 secondes puis se supprime
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)  # Fade out vers alpha 0
	tween.tween_callback(ghost.queue_free)          # Suppression du nœud à la fin
