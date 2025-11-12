extends CanvasLayer

@onready var life_container = $LifeContainer  # ton HBoxContainer ou autre


func _ready() -> void:
	update_vie()
	$Fond.hide()
	$"Menu Button".hide()
	$"Restart Button".hide()
	$"Back Button".hide()
	
func _process(delta: float) -> void:
	pass

func update_vie():
	# Supprimer les icônes précédentes
	for child in life_container.get_children():
		child.queue_free()
	print("nonon")
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
