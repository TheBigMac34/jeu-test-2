extends Node2D

@export var hauteur := 16
@export var duree := 0.25

func start_animation():
	Global.coins += 1  # 💰 +1 pièce
	set_as_top_level(true) 
	var start_pos = global_position
	var end_pos = global_position + Vector2(0, -hauteur)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, duree / 2)
	tween.tween_property(self, "global_position", start_pos, duree / 2)
	tween.finished.connect(queue_free)
	$AudioStreamPlayer.play()
	#print("START:", global_position)

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
