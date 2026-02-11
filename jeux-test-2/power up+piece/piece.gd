extends Node2D

var piece_recup = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and piece_recup:
		piece_recup = false
		Global.coins += 1  # 💰 +1 pièce
		$AudioStreamPlayer.play()
		$Area2D/AnimatedSprite2D.visible = false
		$Area2D.monitoring = false
		await $AudioStreamPlayer.finished
		queue_free()
