extends CharacterBody2D

@onready var player = $"."
@onready var over = preload("res://Game Over/Game Over.tscn")
@onready var animation = $AnimatedSprite2D
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var timer = $CanvasLayer/Timer
@export var start_position: Vector2

var last_checkpoint: Vector2
var time_left := 300
var invincible = false
var blink_timer := 2.0

@export var Y_LIMITE = 100  # Choisis une valeur assez basse selon ton niveau
@export var INVINCIBILITY_TIME := 2.0
@export var BLINK_INTERVAL := 0.1
@export var SPEED = 200
@export var JUMP_VELOCITY = -300

func _on_timer_timeout() -> void:
	time_left -= 1
	update_timer_label()
	if time_left <= 0:
		timer.stop()
		Global.game_over() 
		print("Temps écoulé !")
		# Tu peux appeler une fonction ici pour déclencher un game over ou autre

func update_timer_label():
	timer_label.text = str(time_left) + ""

func _ready() -> void:
	timer.start()

	var spawn_point = get_parent().get_node("SpawnPoint")

	if Global.checkpoint_position != Vector2.ZERO:
		player.global_position = Global.checkpoint_position
		print("🎯 Spawn au checkpoint")

	else:
		global_position = spawn_point.global_position
		print("Spawn au début du niveau")


func _physics_process(delta: float) -> void:

	if position.y > Y_LIMITE:
		Global.game_over()  # Ou appelle directement une fonction de mort
	if invincible:
		blink_timer+=delta
		# Rendre visible/invisible toutes les BLINK_INTERVAL (secondes)
		if int(blink_timer / BLINK_INTERVAL) % 2 == 0:
			animation.visible = false
		else:
			animation.visible = true


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	#jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$"Jumps Sound".play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction < 0: #spite flip
		animation.flip_h = false
	elif direction > 0:
		animation.flip_h = true
	
	if  Input.is_action_pressed("ui_left"):
		animation.play("player 1")
	elif Input.is_action_pressed("ui_right"):
		animation.play("player 1")
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# 🔍 Détection des collisions (coup de tête)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Si le joueur tape PAR DESSOUS
		if collision.get_normal().y > 0.9:
			if collider.has_method("casser"):
				collider.casser()

# systeme de vie 

func take_damage(): 
	if invincible:
		return
	Global.perdre_vie()
	if Global.vies_actuelles <= 0:
		call_deferred("_go_to_game_over")
		return
	var ui = get_tree().current_scene.get_node_or_null("ui")
	if ui:
		ui.update_vie()
	print("outch") 
	$"Damage Sond".play()
	invincible = true
	blink_timer = 0.0
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	invincible = false
	animation.visible = true  # Assure qu'il redevienne visible à la fin

func bounce():
	velocity.y = -400  # Ajuste la valeur pour le rebond
