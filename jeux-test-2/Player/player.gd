extends CharacterBody2D

@onready var animation = $AnimatedSprite2D

const SPEED = 200
const JUMP_VELOCITY = -300


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	print("outch") 
