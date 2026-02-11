extends Node2D

var CheckPoint_Manager
var last_location

@onready var sprite = $Area2D/AnimatedSprite2D
@onready var respawn_point = $RespownPoint

func _ready() -> void:
	Global.load_checkpoint()
	CheckPoint_Manager = get_parent().get_node("CheckPoint Manager")

	# 🔁 RESTAURATION VISUELLE
	if Global.last_checkpoint_position == respawn_point.global_position:
		sprite.play("Green")
	else:
		sprite.play("Red")



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if $Area2D/AnimatedSprite2D.animation == "Red":
			$AudioStreamPlayer.play()
		last_location = $RespownPoint.global_position
		Global.last_checkpoint_position = last_location
		print("✅ Checkpoint sauvegardé :", last_location)
		$Area2D/AnimatedSprite2D.play("Green")
		Global.save_checkpoint(respawn_point.global_position)
