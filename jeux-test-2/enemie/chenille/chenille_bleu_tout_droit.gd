extends CharacterBody2D

@onready var player_camera := get_viewport().get_camera_2d()
@export var speed := -1
@export var gravity := 800

var direction := 1  # -1 = gauche, 1 = droite

const Y_LIMITE = 100  # Choisis une valeur assez basse selon ton niveau

func _ready():
	pass

func _process(delta: float) -> void:
	if player_camera:
		var cam_pos = player_camera.global_position
		var screen_size = get_viewport_rect().size
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size)

		visible = visible_zone.has_point(global_position)
		#print("vue")
	global_position.x += speed

func _physics_process(delta):
	if position.y > Y_LIMITE:
		queue_free()
		print("MORT")
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = speed * direction
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  
		body.take_damage()  
		print("hit chenille bleu")
