extends Node2D

signal level_completed

@export var save_key: String = "level_1_1"          # clé dans le fichier de save
@export var piece_objectif_key: String = "Lvl_1_1"  # clé pour les pièces objectif

var fini := false
var save_path = "user://savegame.json"
var state = "idle"  # idle, descend, monte
var speed = 75

func _ready():
	$Area2D/AnimatedSprite2D.play("Red")

func _process(delta):
	match state:
		"descend":
			_move_flag_toward($Bas.global_position, delta)
		"monte":
			_move_flag_toward($Haut.global_position, delta)

func _move_flag_toward(target_pos: Vector2, delta):
	var flag = $Area2D/AnimatedSprite2D
	flag.global_position = flag.global_position.move_toward(target_pos, speed * delta)
	if flag.global_position.distance_to(target_pos) < 2:
		if state == "descend":
			$Area2D/AnimatedSprite2D.play("Green")
			state = "monte"
		elif state == "monte":
			state = "idle"

func _on_area_2d_body_entered(body):
	if not fini and body.is_in_group("Player"):
		emit_signal("level_completed")
		#print("fin du niveau")
		# Arrête la musique du niveau si elle existe
		if get_tree().current_scene.has_method("level_completed"):
			get_tree().current_scene.level_completed()
		$Musique_Fin.play()
		state = "descend"
		$Timer.start()
		fini = true
		body.figer()
		_start_fireworks()

func _start_fireworks():
	var timer_feux = Timer.new()
	add_child(timer_feux)
	timer_feux.wait_time = 0.4
	timer_feux.timeout.connect(_spawn_firework)
	timer_feux.start()
	$Timer.timeout.connect(timer_feux.stop, CONNECT_ONE_SHOT)
	# Première explosion immédiate
	_spawn_firework()

func _spawn_firework():
	var p = CPUParticles2D.new()
	add_child(p)
	p.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-220, -40))
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.98
	p.amount = 60
	p.lifetime = 1.6
	p.spread = 180.0
	p.gravity = Vector2(0, 120)
	p.initial_velocity_min = 100.0
	p.initial_velocity_max = 220.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 7.0
	# Freinage : les particules ralentissent et retombent naturellement
	p.damping_min = 60.0
	p.damping_max = 100.0
	# Légère accélération radiale pour un effet d'explosion plus naturel
	p.radial_accel_min = 10.0
	p.radial_accel_max = 30.0
	# Courbe de taille : grande au début, disparaît à la fin
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.7, 0.5))
	curve.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = curve
	# Couleur avec fondu vers transparent
	var couleurs = [Color.RED, Color.YELLOW, Color.CYAN, Color.LIME_GREEN, Color.MAGENTA, Color.ORANGE, Color(1.0, 0.6, 0.1), Color.WHITE]
	var c = couleurs[randi() % couleurs.size()]
	var gradient = Gradient.new()
	gradient.set_color(0, c)
	gradient.set_color(1, Color(c.r, c.g, c.b, 0.0))
	p.color_ramp = gradient
	await get_tree().create_timer(p.lifetime + 0.3).timeout
	p.queue_free()

func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://CP+Fin/fin_niveau.tscn")

func _on_level_completed() -> void:
	#print("save")
	var data = _load_save()

	# Bronze : niveau terminé
	Global.medaille_bronze = true
	data[save_key + "_done"] = true

	# Argent : 20 pièces ramassées OU déjà gagné dans une session précédente
	Global.medaille_argent = Global.coins >= 20 or data.get(save_key + "_silver", false)
	if Global.medaille_argent:
		data[save_key + "_silver"] = true

	# Or : toutes les pièces objectif OU déjà gagné dans une session précédente
	var all_ok := true
	for i in range(1, 6):
		var key := "piece_objectif_%d" % i
		if not Global.is_piece_objectif_collected(piece_objectif_key, key):
			all_ok = false
			break
	Global.medaille_or = all_ok or data.get(save_key + "_gold", false)
	if Global.medaille_or:
		data[save_key + "_gold"] = true

	# Retenir le chemin du niveau pour le bouton Rejouer
	Global.current_level_scene = get_tree().current_scene.scene_file_path

	_save_game(data)
	Global.data = data

func _load_save() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var result = JSON.parse_string(file.get_as_text())
		file.close()
		if result is Dictionary:
			return result
	return {}

func _save_game(data: Dictionary) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
