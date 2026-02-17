extends CanvasLayer

@onready var life_container = $LifeContainer  # ton HBoxContainer ou autre
@onready var label = $TextureRect/Label

#progres bar 
@onready var bar_fill = $ProgressContainer/BarFill
@onready var bar_background = $ProgressContainer/BarBackground
@onready var player_icon = $ProgressContainer/PlayerIcon
@onready var progress_bar = $ProgressContainer/ProgressBar
var best_percent := 0.0 # la meilleure progression atteinte (0..1)

var player: Node2D
var start_x := 0.0
var end_x := 1.0

func setup_progress(p: Node2D,level_start_x: float, level_end_x: float) -> void:
	player = p
	start_x = level_start_x
	end_x = level_end_x

#progres bar 

func _ready() -> void:
	update_vie()
	$Fond.hide()
	$"Menu Button".hide()
	$"Restart Button".hide()
	$"Back Button".hide()
	
func _process(delta: float) -> void:
	label.text = str(Global.coins) + "/10" # sa c pour les coin a changer plus tard
	# progress bar
	if player != null:
		var percent = ((player.global_position.x - start_x) / (end_x - start_x)) * 100.0 
		progress_bar.value = clamp(percent, 0.0, 100.0)
		# empêche de reculer : on garde la valeur max atteinte
		
		best_percent = max(best_percent, percent)
		
		
		# 0..1
		var t = (player.global_position.x - start_x) / (end_x - start_x) #pour reprendre l'avancer du joueur  
		t = clamp(t, 0.0, 1.0) # l'encadre en 0 et 1 
		
		var total_width = bar_background.size.x # sa  c pour le max de la barre blanche pour pas quelle depase 
		
		# Remplissage : 0..total_width
		var fill_w = total_width * t # le remplisage selon t. Genre le total c 10 si t =0.25 le remplisage et a 25% 
		bar_fill.size.x = fill_w # si t = 0.5, alors fill_w = 50% de la barre 
		
		# Icône (Sprite2D) : on prend la largeur de la texture
		var tex: Texture2D = player_icon.texture
		var icon_w := 0.0
		if tex != null:
			icon_w = tex.get_size().x * abs(player_icon.scale.x)

		# Sprite2D est centré, donc on clamp sa position (centre) dans la barre
		var icon_x = clamp(fill_w, 0.0, total_width) 
		player_icon.position.x = icon_x 


func update_vie():
	# Supprimer les icônes précédentes
	for child in life_container.get_children():
		child.queue_free()
	# print("nonon")
	# Ajouter autant de vies que dans Global
	for i in Global.vies_actuelles:
		var coeur = TextureRect.new()
		coeur.texture = preload("res://base de donné image/kenney_pixel-platformer/Tiles/tile_0044.png")
		coeur.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		life_container.add_child(coeur)



func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$Fond.show()
	$"Pause Button".hide()
	$"Menu Button".show()
	$"Restart Button".show()
	$"Back Button".show()
	#print("pause")


func _on_back_button_pressed() -> void:
	get_tree().paused = false
	$Fond.hide()
	$"Menu Button".hide()
	$"Restart Button".hide()
	$"Back Button".hide()
	$"Pause Button".show()


func _on_menu_button_pressed() -> void:
	Global.clear_checkpoint()
	Global.coins = 0 
	get_tree().paused = false
	$Fond.hide()
	$"Menu Button".hide()
	$"Restart Button".hide()
	$"Back Button".hide()
	$"Pause Button".show()
	var menu_principale = load("res://Menu/menu_principal.tscn")
	get_tree().change_scene_to_packed(menu_principale)
	print("menu principale")
	Global.last_checkpoint_position = Vector2.ZERO
	#print("Menu principale :", menu_principale)


func _on_restart_button_pressed() -> void:
	Global.clear_checkpoint()
	Global.coins = 0 
	$Fond.hide()
	$"Menu Button".hide()
	$"Restart Button".hide()
	$"Back Button".hide()
	$"Pause Button".show()
	get_tree().paused = false
	Global.last_checkpoint_position = Vector2.ZERO  # 🔹 On efface le dernier checkpoint
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()  # 🔹 Recharge le niveau depuis le début
	print("RESTART")
	Global.last_checkpoint_position = Vector2.ZERO
