extends Control

@onready var first_level = preload("res://lvl 1/lvl_1_1.tscn")
@onready var second_level = preload("res://lvl 1/lvl_1_2.tscn")
@onready var bronze_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/Bronze 1-1"
@onready var argent_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/argent1-1"
@onready var gold_sprite = $"Level 1/VBoxContainer/Level 1-1/VBoxContainer/or 1-1"

var save_path = "user://savegame.json"

func init_save_if_needed():
	if not FileAccess.file_exists(save_path):
		print("Création de la sauvegarde par défaut")
		var default_data = {
			"level_1_1_done": false,
			"level_1_1_silver": false,
			"level_1_1_gold": false
		}
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(default_data))
		file.close()

func apply_default_medals():
	bronze_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png")
	argent_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png")
	gold_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png")




func load_save():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return {}

func save_game(data):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func apply_bronze_reward():
	bronze_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076.png")

func apply_silver_reward():
	argent_sprite.texture = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0077.png")


func _ready() -> void:
	init_save_if_needed()
	
	$"Main Menu Music".play()
	$Reset.hide()
	$"Chose your level".show()
	$"Main Menu".show()
	$back.hide()
	$"Level 1".hide()
	$"Level 1/VBoxContainer".hide()
	var data = load_save()
	if data.get("level_1_1_done", false) == true:
		apply_bronze_reward()
	else:
		apply_default_medals()
	if data.get("level_1_1_silver", false) == true:
		apply_silver_reward()
	else:
		apply_default_medals()



func _on_chose_your_level_pressed() -> void:
	#print("test")
	$Reset.show()
	$"Chose your level".hide()
	$"Main Menu".hide()
	$back.show()
	$"Level 1".show()
	$Quit.hide()

func _on_back_pressed() -> void:
	$Reset.hide()
	$"Chose your level".show()
	$"Main Menu".show()
	$back.hide()
	$"Level 1".hide()
	$"Level 1/VBoxContainer".hide()
	$Quit.show()

func _on_level_1_pressed() -> void:
	Global.clear_checkpoint()
	var box = $"Level 1/VBoxContainer"
	box.visible = not box.visible
	Global.vies_actuelles = 3
	#print("niveau 1")

func _on_level_11_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)
	Global.dernier_niveau_path = "res://lvl 1/lvl_1_1.tscn"
	Global.coins = 0 


func _on_level_12_pressed() -> void:
	get_tree().change_scene_to_packed(second_level)
	Global.dernier_niveau_path = "res://lvl 1/lvl_1_2.tscn"
	Global.coins = 0 

func _on_quit_pressed() -> void:
	get_tree().quit()  

 


func _on_reset_pressed() -> void:
	var default_data = {
		"level_1_1_done": false,
		"level_1_1_silver": false,
		"level_1_1_gold": false
	}

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(default_data))
	file.close()

	apply_default_medals()
	print("Reset")
