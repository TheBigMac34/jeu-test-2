extends CharacterBody2D

@export var speed := 40
@export var gravity := 800

var direction := 1  # -1 = gauche, 1 = droite

@onready var ground_check = $RayCast2D
@onready var wall_check = $WallCheck
@onready var sprite = $death/AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	_update_raycast_positions()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0


	# Si pas de sol ou mur devant → demi-tour
	if not ground_check.is_colliding():
		print("vue sol")
		direction *= -1
		sprite.flip_h = direction > 0
		_update_raycast_positions()
		
	if wall_check.is_colliding():
		print("vue mur")
		direction *= -1
		sprite.flip_h = direction > 0
		_update_raycast_positions()



	# Déplacement horizontal
	velocity.x = speed * direction
	move_and_slide()

func _update_raycast_positions():
	var offset_x = 10
	ground_check.position.x = offset_x * direction
	wall_check.position.x = offset_x * direction

	# Le sol → toujours vers le bas
	ground_check.target_position = Vector2(0, 16)

	# Le mur → dans la direction du déplacement (8 pixels vers la gauche ou droite)
	wall_check.target_position = Vector2(1 * direction, 0)

func _on_death_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  
		body.take_damage()  
		#print("hit chenille bleu")
