extends Node

@onready var over = preload("res://Game Over/Game Over.tscn")

var vies_max = 3
var vies_actuelles = vies_max
var dernier_niveau_path: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

signal heal

func perdre_vie():
	vies_actuelles -= 1
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)
	print("Vies restantes : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.update_vie()
	if vies_actuelles <= 0:
		game_over()


func gagner_vie():
	vies_actuelles += 1
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)
	print("Vies actuelles après soin : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.update_vie()
	emit_signal("heal")





func game_over():
	print("GAME OVER !")
	get_tree().change_scene_to_packed(over)
	#get_tree().change_scene_to_file("res://game_over.tscn")  # ou autre scène
