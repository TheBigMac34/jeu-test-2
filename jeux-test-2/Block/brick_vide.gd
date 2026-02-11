extends StaticBody2D


@export var cassable := true

func casser():
	if cassable:
		$AudioStreamPlayer.play()
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y - 6, 0.05)
		tween.tween_property(self, "position:y", position.y, 0.05)
		tween.finished.connect(queue_free)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
