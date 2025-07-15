extends Area2D

@onready var player_camera := get_viewport().get_camera_2d()
@onready var speed = -2
@onready var left_limit = $"../Left Limite"
@onready var right_limit = $"../Right Limite"
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if player_camera:
		var cam_pos = player_camera.global_position
		var screen_size = get_viewport_rect().size
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size)
		visible = visible_zone.has_point(global_position)
	if visible:
		#print("vue")
		pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("take_damage"):  
			body.take_damage()  
			print("hit mobs 1 mouv")



func  _physics_process(delta: float) -> void:
	global_position.x += speed
	if global_position.x >= right_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = false
	elif global_position.x <= left_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = true

func _on_top_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("bounce"):
			body.bounce()
		queue_free()
