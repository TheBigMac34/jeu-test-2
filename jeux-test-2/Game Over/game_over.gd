extends CanvasLayer
@onready var menu_principale = preload("res://Menu/menu_principal.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()




func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(menu_principale)
	Global.last_checkpoint_position = Vector2.ZERO


func _on_restart_pressed() -> void:
	if Global.dernier_niveau_path != "":
		get_tree().change_scene_to_file(Global.dernier_niveau_path)
	else:
		print("Aucun niveau précédent enregistré.")
	Global.vies_actuelles = 3
