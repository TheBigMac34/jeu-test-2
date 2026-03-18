extends Node2D

# --- SIGNAUX ---
signal level_completed # Signal émis quand le joueur atteint le drapeau de fin

# --- VARIABLES EXPORTÉES ---
@export var save_key: String = "level_1_1"          # Clé utilisée dans le fichier de sauvegarde (ex: "level_1_1_done")
@export var piece_objectif_key: String = "Lvl_1_1"  # Clé pour identifier les pièces objectif du niveau dans Global

# --- VARIABLES D'ÉTAT ---
var fini := false # Indique si le drapeau a déjà été déclenché (évite les déclenchements multiples)
var save_path = "user://savegame.json" # Chemin du fichier de sauvegarde JSON
var state = "idle"  # État actuel du drapeau : "idle" (immobile), "descend" (descend), "monte" (remonte)
var speed = 75 # Vitesse de déplacement du sprite du drapeau en pixels par seconde

# --- INITIALISATION ---
func _ready():
	$Area2D/AnimatedSprite2D.play("Red") # Joue l'animation rouge du drapeau au démarrage (pas encore atteint)

# --- BOUCLE PRINCIPALE ---
func _process(delta):
	match state: # Vérifie l'état actuel du drapeau pour déterminer l'action à effectuer
		"descend":
			_move_flag_toward($Bas.global_position, delta) # Déplace le sprite du drapeau vers le bas
		"monte":
			_move_flag_toward($Haut.global_position, delta) # Déplace le sprite du drapeau vers le haut

# --- DÉPLACEMENT DU DRAPEAU ---
func _move_flag_toward(target_pos: Vector2, delta):
	var flag = $Area2D/AnimatedSprite2D # Récupère le sprite animé du drapeau
	flag.global_position = flag.global_position.move_toward(target_pos, speed * delta) # Déplace le sprite vers la cible à la vitesse définie
	if flag.global_position.distance_to(target_pos) < 2: # Vérifie si le sprite est suffisamment proche de la cible (seuil de 2 pixels)
		if state == "descend": # Si le drapeau venait de descendre
			$Area2D/AnimatedSprite2D.play("Green") # Passe l'animation en vert (niveau terminé)
			state = "monte" # Passe à l'état de remontée
		elif state == "monte": # Si le drapeau venait de remonter
			state = "idle" # Revient à l'état immobile

# --- SIGNAL : JOUEUR ENTRE DANS LA ZONE ---
func _on_area_2d_body_entered(body):
	if not fini and body.is_in_group("Player"): # Vérifie que le niveau n'est pas déjà terminé et que c'est le joueur
		emit_signal("level_completed") # Émet le signal de fin de niveau pour déclencher la sauvegarde des médailles
		#print("fin du niveau") # Debug désactivé
		# Arrête la musique du niveau si elle existe
		if get_tree().current_scene.has_method("level_completed"): # Vérifie si la scène du niveau a une méthode level_completed
			get_tree().current_scene.level_completed() # Appelle la méthode de fin de niveau sur la scène principale
		$Musique_Fin.play() # Lance la musique de fin de niveau
		state = "descend" # Déclenche l'animation de descente du drapeau
		$Timer.start() # Démarre le timer qui déclenchera la transition vers la scène de fin
		fini = true # Marque le niveau comme terminé pour éviter tout re-déclenchement
		body.figer() # Fige le joueur : bloque ses inputs tout en maintenant la physique
		_start_fireworks() # Lance les feux d'artifice de célébration

# --- FEUX D'ARTIFICE ---
func _start_fireworks():
	var timer_feux = Timer.new() # Crée un nouveau Timer pour spawner les feux d'artifice régulièrement
	add_child(timer_feux) # Ajoute le timer comme enfant de ce nœud
	timer_feux.wait_time = 0.4 # Définit l'intervalle entre chaque feu d'artifice (0.4 secondes)
	timer_feux.timeout.connect(_spawn_firework) # Connecte le signal timeout pour spawner un feu d'artifice à chaque tick
	timer_feux.start() # Démarre le timer des feux d'artifice
	$Timer.timeout.connect(timer_feux.stop, CONNECT_ONE_SHOT) # Arrête le timer des feux d'artifice en même temps que la transition de scène (connexion unique)
	# Première explosion immédiate dès le début
	_spawn_firework() # Déclenche immédiatement un premier feu d'artifice sans attendre le timer

# --- SPAWN D'UN FEU D'ARTIFICE ---
func _spawn_firework():
	var p = CPUParticles2D.new() # Crée un nouveau système de particules CPU
	add_child(p) # Ajoute le système de particules comme enfant de ce nœud
	p.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-220, -40)) # Positionne le feu d'artifice à une position aléatoire autour du drapeau
	p.emitting = true # Active immédiatement l'émission des particules
	p.one_shot = true # Les particules ne s'émettent qu'une seule fois (pas en boucle)
	p.explosiveness = 0.98 # Toutes les particules sont émises presque simultanément (effet d'explosion)
	p.amount = 60 # Nombre total de particules émises par explosion
	p.lifetime = 1.6 # Durée de vie de chaque particule en secondes
	p.spread = 180.0 # Angle de dispersion des particules en degrés (tous les sens)
	p.gravity = Vector2(0, 120) # Gravité appliquée aux particules pour les faire retomber naturellement
	p.initial_velocity_min = 100.0 # Vitesse initiale minimale des particules
	p.initial_velocity_max = 220.0 # Vitesse initiale maximale des particules
	p.scale_amount_min = 3.0 # Taille minimale des particules
	p.scale_amount_max = 7.0 # Taille maximale des particules
	# Freinage : les particules ralentissent et retombent naturellement
	p.damping_min = 60.0 # Freinage minimal appliqué aux particules (ralentissement progressif)
	p.damping_max = 100.0 # Freinage maximal appliqué aux particules
	# Légère accélération radiale pour un effet d'explosion plus naturel
	p.radial_accel_min = 10.0 # Accélération radiale minimale (pousse les particules vers l'extérieur)
	p.radial_accel_max = 30.0 # Accélération radiale maximale
	# Courbe de taille : grande au début, disparaît à la fin
	var curve = Curve.new() # Crée une courbe d'animation pour la taille des particules
	curve.add_point(Vector2(0.0, 1.0)) # Taille maximale au début de vie de la particule
	curve.add_point(Vector2(0.7, 0.5)) # Taille réduite à 70% de la durée de vie
	curve.add_point(Vector2(1.0, 0.0)) # Taille nulle à la fin de vie (disparition progressive)
	p.scale_amount_curve = curve # Applique la courbe de taille aux particules
	# Couleur avec fondu vers transparent
	var couleurs = [Color.RED, Color.YELLOW, Color.CYAN, Color.LIME_GREEN, Color.MAGENTA, Color.ORANGE, Color(1.0, 0.6, 0.1), Color.WHITE] # Palette de couleurs possibles pour les feux d'artifice
	var c = couleurs[randi() % couleurs.size()] # Choisit une couleur aléatoire dans la palette
	var gradient = Gradient.new() # Crée un dégradé pour la couleur des particules
	gradient.set_color(0, c) # Couleur de départ : la couleur choisie aléatoirement (opaque)
	gradient.set_color(1, Color(c.r, c.g, c.b, 0.0)) # Couleur de fin : la même mais transparente (fondu vers invisible)
	p.color_ramp = gradient # Applique le dégradé de couleur aux particules
	await get_tree().create_timer(p.lifetime + 0.3).timeout # Attend que les particules aient fini leur durée de vie + une petite marge
	p.queue_free() # Supprime le système de particules de la scène après son utilisation

# --- TIMER DE FIN DE NIVEAU ---
func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://CP+Fin/fin_niveau.tscn") # Change la scène vers l'écran de fin de niveau de façon différée (évite les erreurs de signal)

# --- SAUVEGARDE DES MÉDAILLES ---
func _on_level_completed() -> void:
	#print("save") # Debug désactivé
	var data = _load_save() # Charge les données de sauvegarde existantes depuis le fichier JSON

	# Bronze : niveau terminé
	Global.medaille_bronze = true # Attribue toujours la médaille bronze quand le niveau est terminé
	data[save_key + "_done"] = true # Marque le niveau comme complété dans la sauvegarde

	# Argent : 20 pièces ramassées OU déjà gagné dans une session précédente
	Global.medaille_argent = Global.coins >= 20 or data.get(save_key + "_silver", false) # Argent si 20 pièces collectées cette session OU médaille déjà obtenue avant
	if Global.medaille_argent: # Si la condition argent est remplie
		data[save_key + "_silver"] = true # Enregistre la médaille argent dans la sauvegarde

	# Or : toutes les pièces objectif OU déjà gagné dans une session précédente
	var all_ok := true # On suppose que toutes les pièces objectif ont été collectées
	for i in range(1, 6): # Boucle sur les 5 pièces objectif possibles (1 à 5)
		var key := "piece_objectif_%d" % i # Construit la clé de la pièce objectif (ex: "piece_objectif_1")
		if not Global.is_piece_objectif_collected(piece_objectif_key, key): # Vérifie si cette pièce objectif a bien été collectée
			all_ok = false # Si une pièce manque, la condition or est non remplie
			break # Inutile de continuer à vérifier les autres pièces
	Global.medaille_or = all_ok or data.get(save_key + "_gold", false) # Or si toutes les pièces objectif collectées OU médaille déjà obtenue avant
	if Global.medaille_or: # Si la condition or est remplie
		data[save_key + "_gold"] = true # Enregistre la médaille or dans la sauvegarde

	# Retenir le chemin du niveau actuel pour le bouton Rejouer dans l'écran de fin
	Global.current_level_scene = get_tree().current_scene.scene_file_path # Sauvegarde le chemin de la scène du niveau courant dans Global

	_save_game(data) # Écrit les données mises à jour dans le fichier de sauvegarde
	Global.data = data # Met à jour les données de sauvegarde dans le singleton Global

# --- CHARGEMENT DE LA SAUVEGARDE ---
func _load_save() -> Dictionary:
	if FileAccess.file_exists(save_path): # Vérifie si le fichier de sauvegarde existe
		var file = FileAccess.open(save_path, FileAccess.READ) # Ouvre le fichier en lecture
		var result = JSON.parse_string(file.get_as_text()) # Parse le contenu JSON du fichier
		file.close() # Ferme le fichier après lecture
		if result is Dictionary: # Vérifie que le JSON parsé est bien un dictionnaire valide
			return result # Retourne les données de sauvegarde
	return {} # Retourne un dictionnaire vide si le fichier n'existe pas ou si le JSON est invalide

# --- ÉCRITURE DE LA SAUVEGARDE ---
func _save_game(data: Dictionary) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE) # Ouvre le fichier en écriture (écrase le contenu existant)
	file.store_string(JSON.stringify(data)) # Convertit le dictionnaire en JSON et l'écrit dans le fichier
	file.close() # Ferme le fichier après écriture
