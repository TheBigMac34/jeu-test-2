extends Node2D

signal level_completed

var fini := false
var save_path = "user://savegame.json"
var state = "idle"  # idle, descend, change_color, monte
var speed = 75
var fin = preload("res://Menu/menu_principal.tscn")

func _ready():
	$Area2D/AnimatedSprite2D.play("Red")  # Le drapeau est rouge au début

func _process(delta):
	match state:
		"descend":
			_move_flag_toward($Bas.global_position, delta)
			
		"monte":
			_move_flag_toward($Haut.global_position, delta)


# Fonction de déplacement
func _move_flag_toward(target_pos: Vector2, delta):
	var flag = $Area2D/AnimatedSprite2D
	flag.global_position = flag.global_position.move_toward(target_pos, speed * delta)

	# Arrivé à destination
	if flag.global_position.distance_to(target_pos) < 2:
		if state == "descend":
			# Étape 2 : changer la couleur
			$Area2D/AnimatedSprite2D.play("Green")
			state = "monte"   # Ensuite monter
		elif state == "monte":
			state = "idle"   # Fin des animations


func _on_area_2d_body_entered(body):
	if not fini and body.is_in_group("Player"):
		emit_signal("level_completed")
		print("fin du niveau")
		$Musique_Fin.play()
		state = "descend"
		$Timer.start()
		fini = true


#save systeme

func load_save():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return {}  # si aucune sauvegarde

func save_game(data):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func _on_timer_timeout() -> void:
	print("timer")
	get_tree().change_scene_to_packed(fin)


func _on_level_completed() -> void:
	print("save")
	var data = load_save()
	data["level_1_1_done"] = true
	save_game(data)
