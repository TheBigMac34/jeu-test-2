extends Node2D

@onready var player_camera := get_viewport().get_camera_2d()
var invincible_to_player := false
var damage : = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_camera:
		var cam_pos = player_camera.global_position
		var screen_size = get_viewport_rect().size
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size)
		visible = visible_zone.has_point(global_position)
	if visible:
		#print("vue")
		pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not invincible_to_player:
		if body.has_method("take_damage"):  
			body.take_damage()  
			queue_free()
			damage = true 
			print("hit mobs 1 imo")



func _on_top_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not damage :
		if body.has_method("bounce"):
			body.bounce()
		invincible_to_player = true
		await get_tree().create_timer(0.05).timeout
		queue_free()
