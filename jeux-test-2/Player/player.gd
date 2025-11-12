extends CharacterBody2D

@onready var over = preload("res://Game Over/Game Over.tscn")
@onready var animation = $AnimatedSprite2D
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var timer = $CanvasLayer/Timer
@export var start_position: Vector2

var last_checkpoint: Vector2
var time_left := 300
var invincible = false
var blink_timer := 2.0

const Y_LIMITE = 100  # Choisis une valeur assez basse selon ton niveau
const INVINCIBILITY_TIME := 2.0
const BLINK_INTERVAL := 0.1
const SPEED = 200
const JUMP_VELOCITY = -300

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
	global_position = spawn_point.global_position
	if Global.last_checkpoint_position != Vector2.ZERO:
		global_position = Global.last_checkpoint_position
		print("Respawn au dernier checkpoint :", Global.last_checkpoint_position)



func _physics_process(delta: float) -> void:
	if position.y > Y_LIMITE:
		Global.game_over()  # Ou appelle directement une fonction de mort
	if invincible:
		blink_timer+=delta
		# Rendre visible/invisible toutes les BLINK_INTERVAL (secondes)
		if int(blink_timer / BLINK_INTERVAL) % 2 == 0:
			$AnimatedSprite2D.visible = false
		else:
			$AnimatedSprite2D.visible = true


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$"Jumps Sound".play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction < 0:
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
	$AnimatedSprite2D.visible = true  # Assure qu'il redevienne visible à la fin

func bounce():
	velocity.y = -400  # Ajuste la valeur pour le rebond
