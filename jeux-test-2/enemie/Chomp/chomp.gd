extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D
@export var fall_speed := 600.0
@export var rise_speed := 100.0
@export var wait_time := 0.5  # temps d’attente avant de remonter

var player_in_zone := false
var is_falling := false
var is_rising := false
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position
	anim_sprite.play("idle")

func _physics_process(delta):
	if is_falling:
		velocity.y = fall_speed
		move_and_slide()
		if is_on_floor():
			is_falling = false
			anim_sprite.play("impact")
			await get_tree().create_timer(wait_time).timeout
			is_rising = true
			anim_sprite.play("rise")

	elif is_rising:
		var direction = (start_position - global_position).normalized()
		velocity = direction * rise_speed
		move_and_slide()
		if global_position.distance_to(start_position) < 5:
			global_position = start_position
			velocity = Vector2.ZERO
			is_rising = false
			anim_sprite.play("idle")

	else:
		velocity = Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if not is_falling and not is_rising:
			is_falling = true
			anim_sprite.play("fall")


func _on_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if not is_falling and not is_rising:
			is_falling = false
			anim_sprite.play("detection")


func _on_damage_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  
		body.take_damage()  
		print("hit chomp")
