extends Button

@export var hover_scale := 1.1
@export var duration := 0.10

var base_scale: Vector2
var tween: Tween

func _ready():
	pivot_offset = size / 2
	base_scale = scale

	# Souris
	mouse_entered.connect(_apply_hover)
	mouse_exited.connect(_remove_hover)

	# Manette / clavier (focus)
	focus_entered.connect(_apply_hover)
	focus_exited.connect(_remove_hover)

	# Important : autoriser le focus
	focus_mode = Control.FOCUS_ALL


func _apply_hover():
	_kill_tween()
	tween = create_tween()
	tween.tween_property(self, "scale", base_scale * hover_scale, duration)


func _remove_hover():
	_kill_tween()
	tween = create_tween()
	tween.tween_property(self, "scale", base_scale, duration)


func _kill_tween():
	if tween and tween.is_valid():
		tween.kill()
