extends Button

@export var hover_scale := 1.1
@export var duration := 0.10

var base_scale: Vector2
var tween: Tween

@export var level_id := "1_1"   # juste pour construire les clés

@export var normal_color: Color = Color.WHITE
@export var gold_color: Color = Color("dfec11") # ton jaune/or

func _ready() -> void:
	update_visual()
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

func _load_save_file() -> Dictionary:
	if not FileAccess.file_exists(Global.save_path):
		return {}
	var f := FileAccess.open(Global.save_path, FileAccess.READ)
	if not f:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

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



func update_visual():
	var data := _load_save_file()

	var done   := bool(data.get("level_1_1_done",   false))
	var silver := bool(data.get("level_1_1_silver", false))
	var gold   := bool(data.get("level_1_1_gold",   false))

	# On choisit la couleur selon la meilleure médaille obtenue
	var couleur : Color
	if gold:
		couleur = Color("dfec11")       # Or    → jaune
	elif silver:
		couleur = Color("c0c0c0")       # Argent → gris clair
	elif done:
		couleur = Color("cd7f32")       # Bronze → marron/cuivre
	else:
		couleur = Color.WHITE           # Pas encore fait → blanc

	add_theme_color_override("font_color",         couleur)
	add_theme_color_override("font_hover_color",   couleur)
	add_theme_color_override("font_pressed_color", couleur)
