extends CharacterBody2D

# --- RÉFÉRENCES AUX NOEUDS ---
@onready var player = $"."                          # Référence au joueur lui-même
@onready var over = preload("res://Game Over/Game Over.tscn")  # Scène Game Over préchargée
@onready var animation = $AnimatedSprite2D          # Sprite animé du joueur
@onready var timer_label = $CanvasLayer/TimerLabel  # Label qui affiche le temps restant
@onready var timer = $CanvasLayer/Timer             # Timer qui décompte chaque seconde
@onready var camera = $Camera2D                     # Référence à la caméra du joueur

# --- CAMÉRA JOYSTICK DROIT ---
const CAM_OFFSET_MAX := Vector2(60.0, 80.0)        # Décalage maximum de la caméra en pixels (X et Y)
const CAM_OFFSET_SPEED := 4.0                       # Vitesse de transition du décalage caméra (lerp)
const CAM_DEADZONE := 0.2                           # Zone morte du joystick droit (ignore les micro-mouvements)
var cam_target_offset := Vector2.ZERO               # Décalage cible calculé depuis le joystick
var _cam_half_w: float = 0.0                        # Demi-largeur du viewport en pixels monde (calculée une fois)

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
var was_on_floor: bool = false                      # True si le joueur était au sol la frame précédente

# --- COYOTE TIME ---
var coyote_timer: float = 0.0                       # Temps restant pendant lequel on peut encore sauter après avoir quitté le sol
const COYOTE_TIME: float = 0.1                      # Fenêtre coyote time en secondes (comme Celeste)

# --- JUMP BUFFER ---
var jump_buffer_timer: float = 0.0                  # Temps restant depuis le dernier appui saut (pour sauter dès l'atterrissage)
const JUMP_BUFFER_TIME: float = 0.08               # Fenêtre de temps du jump buffer en secondes

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

	# Gravité appliquée quand le joueur est en l'air (annulée pendant le dash)
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Si le joueur est figé (ex: touche le drapeau de fin), on freine progressivement et on sort
	if fige:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)  # Freinage progressif (sol et air)
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
		velocity.y = 0.0                            # Annule l'élan vertical au démarrage du dash

	# Pendant le dash : vitesse fixe + effet trail + court-circuit du reste
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED   # Vitesse horizontale du dash
		trail_timer += delta
		if trail_timer >= TRAIL_INTERVAL:
			trail_timer = 0.0
			_spawn_trail_ghost()                    # Crée un fantôme à la position actuelle
		move_and_slide()
		return                                      # On ignore le reste du mouvement pendant le dash

	# --- DOUBLE SAUT & COYOTE TIME ---

	# Réinitialise les sauts disponibles quand on touche le sol
	if is_on_floor():
		sauts_restants = 2 if Global.has_double_jump else 1
		coyote_timer = 0.0                          # Pas besoin du coyote time si on est au sol

	# Coyote time : quand on quitte le sol sans sauter, on démarre le timer
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer = COYOTE_TIME                  # On a 0.1s pour encore sauter

	# Décompte du coyote timer
	if coyote_timer > 0:
		coyote_timer -= delta

	was_on_floor = is_on_floor()                    # On mémorise l'état du sol pour la prochaine frame

	# Jump buffer : décompte du timer et enregistrement de l'appui saut
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME        # L'appui est mémorisé pendant 0.08s
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta                  # On diminue le timer chaque frame

	# Peut sauter si : au sol, ou dans la fenêtre coyote, ou double saut disponible
	var peut_sauter = is_on_floor() or coyote_timer > 0 or (Global.has_double_jump and sauts_restants > 0)

	# Saut si le buffer est actif et qu'on peut sauter
	if jump_buffer_timer > 0 and peut_sauter:
		velocity.y = JUMP_VELOCITY
		$"Jumps Sound".play()
		sauts_restants -= 1                         # On consomme un saut
		coyote_timer = 0.0                          # Coyote time consommé
		jump_buffer_timer = 0.0                     # Buffer consommé

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

	# --- DÉCALAGE CAMÉRA JOYSTICK DROIT ---
	var right_stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),   # Axe horizontal du joystick droit
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)    # Axe vertical du joystick droit
	)
	if right_stick.length() < CAM_DEADZONE:         # Ignore les micro-mouvements (zone morte)
		right_stick = Vector2.ZERO
	if _cam_half_w == 0.0:
		_cam_half_w = get_viewport().get_visible_rect().size.x * 0.5 / camera.zoom.x
	cam_target_offset = right_stick * CAM_OFFSET_MAX                        # Calcule le décalage cible
	# Limite gauche X : on borne le TARGET avant le lerp pour éviter tout tremblement
	# La base caméra (sans offset) = sc_x - offset actuel → position stable malgré le smoothing
	if _cam_half_w > 0.0:
		var sc_base_x: float = camera.get_screen_center_position().x - camera.offset.x  # Base caméra sans offset
		if abs(sc_base_x - global_position.x) < 500.0:                      # Sécurité : valeur cohérente seulement
			var target_left_edge: float = sc_base_x + cam_target_offset.x - _cam_half_w  # Bord gauche si target appliqué
			if target_left_edge < -575.0:                                    # Dépasserait la limite
				cam_target_offset.x = -575.0 - sc_base_x + _cam_half_w      # Borne le target pour rester à -575
	camera.offset = camera.offset.lerp(cam_target_offset, CAM_OFFSET_SPEED * delta) # Transition douce vers la cible
	camera.offset = camera.offset.clamp(-CAM_OFFSET_MAX, CAM_OFFSET_MAX)   # Borne l'offset dans tous les sens
	# Limite bas Y : seulement si le joueur est au-dessus de Y=10
	# (en dessous, la formule deviendrait négative et forcerait la caméra vers le haut)
	if global_position.y < 10.0:
		camera.offset.y = minf(camera.offset.y, 10.0 - global_position.y)

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

	# Si le joueur portait la clé, elle tombe et redevient ramassable
	if Global.has_key:
		for k in get_tree().get_nodes_in_group("key"):
			if k.has_method("drop"):
				k.drop()

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
	is_dashing = false                                  # Annule le dash en cours
	dash_timer = 0.0                                    # Remet le timer du dash à zéro

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
