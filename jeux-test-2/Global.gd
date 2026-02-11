extends Node

@onready var over = preload("res://Game Over/Game Over.tscn")

var coins: int = 0
var vies_max = 3
var vies_actuelles = vies_max
var dernier_niveau_path: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

var CHECKPOINT_SAVE := "user://checkpoint.json"
var checkpoint_position : Vector2 = Vector2.ZERO

func save_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos

	var file = FileAccess.open(CHECKPOINT_SAVE, FileAccess.WRITE)
	file.store_var(pos) # Vector2 OK
	file.close()

	#print("💾 Checkpoint sauvegardé :", pos)


func load_checkpoint() -> void:
	if not FileAccess.file_exists(CHECKPOINT_SAVE):
		#print("❌ Aucun checkpoint sauvegardé")
		checkpoint_position = Vector2.ZERO
		return

	var file = FileAccess.open(CHECKPOINT_SAVE, FileAccess.READ)
	var data = file.get_var()
	file.close()

	# 🔐 SÉCURITÉ ANTI-BUG
	if data == null or typeof(data) != TYPE_VECTOR2:
		#print("⚠️ Checkpoint invalide, reset")
		checkpoint_position = Vector2.ZERO
		return

	checkpoint_position = data
	#print("📂 Checkpoint chargé :", checkpoint_position)

func clear_checkpoint() -> void:
	checkpoint_position = Vector2.ZERO
	if FileAccess.file_exists(CHECKPOINT_SAVE):
		DirAccess.remove_absolute(CHECKPOINT_SAVE)
		#print("🗑️ Checkpoint supprimé")




signal heal

func perdre_vie():
	vies_actuelles -= 1
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)
	#print("Vies restantes : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.update_vie()
	if vies_actuelles <= 0:
		game_over()


func gagner_vie():
	vies_actuelles += 1
	vies_actuelles = clamp(vies_actuelles, 0, vies_max)
	#print("Vies actuelles après soin : ", vies_actuelles)
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.update_vie()
	emit_signal("heal")





func game_over():
	#print("GAME OVER !")
	get_tree().change_scene_to_packed(over)
	#get_tree().change_scene_to_file("res://game_over.tscn")  # ou autre scène
