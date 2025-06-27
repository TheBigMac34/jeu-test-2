extends Area2D

@onready var player_camera := get_viewport().get_camera_2d()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# apparais a la camera 
func _process(delta: float) -> void:
	if player_camera:
		var cam_pos = player_camera.global_position
		var screen_size = get_viewport_rect().size
		var visible_zone = Rect2(cam_pos - screen_size / 2, screen_size)

		visible = visible_zone.has_point(global_position)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  
		body.take_damage()  
		print("hit 2")
