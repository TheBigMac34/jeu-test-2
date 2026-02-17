extends Node

@onready var over = preload("res://Game Over/Game Over.tscn")

var save_path = "user://savegame.json"
var data: Dictionary = {}   # ✅ AJOUTE ÇA ICI
var piece_objectif := {}
var levels_data := {}
var coins: int = 0
var vies_max = 3
var vies_actuelles = 2
var dernier_niveau_path: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

var CHECKPOINT_SAVE := "user://checkpoint.json"
var checkpoint_position : Vector2 = Vector2.ZERO

# Médailles de fin de niveau
var medaille_bronze: bool = false
var medaille_argent: bool = false
var medaille_or: bool = false
var current_level_scene: String = ""  # pour le bouton Rejouer

# Power-ups débloqués par le PNJ
var has_dash: bool = false
var has_double_jump: bool = false


func _ready():
	print("SAVE FILE PATH:", ProjectSettings.globalize_path(save_path))
	load_game()

func save_game() -> void:
	# IMPORTANT : on met bien piece_objectif dans data avant d'écrire
	data["piece_objectif"] = piece_objectif
	data["has_dash"] = has_dash
	data["has_double_jump"] = has_double_jump
	var fw := FileAccess.open(save_path, FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(data))
		fw.close()


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

#piece objectif 
func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		data = {}
		piece_objectif = {}
		return

	var f := FileAccess.open(save_path, FileAccess.READ)
	if not f:
		data = {}
		piece_objectif = {}
		return

	var parsed = JSON.parse_string(f.get_as_text())
	f.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		data = {}
		piece_objectif = {}
		return

	data = parsed
	piece_objectif = data.get("piece_objectif", {})
	has_dash = data.get("has_dash", false)
	has_double_jump = data.get("has_double_jump", false)



func is_piece_objectif_collected(level_id: String, piece_objectif_id: String) -> bool:
	var raw = piece_objectif.get(level_id, {}).get(piece_objectif_id, false)

	if raw is bool:
		return raw
	if raw is String:
		return raw.to_lower() == "true"
	if raw is int:
		return raw == 1
	return false


func set_piece_objectif_collected(level_id: String, piece_objectif_id: String) -> void:
	if not piece_objectif.has(level_id):
		piece_objectif[level_id] = {}
	piece_objectif[level_id][piece_objectif_id] = true
	save_game()

func get_piece_objectif_count(level_id: String) -> int:
	if not piece_objectif.has(level_id):
		return 0
	return piece_objectif[level_id].size()

func has_all_piece_objectifs(level_id: String, total := 5) -> bool:
	for i in range(1, total + 1):
		if not is_piece_objectif_collected(level_id, "piece_objectif_%d" % i):
			return false
	return true


func game_over():
	#print("GAME OVER !")
	get_tree().change_scene_to_packed(over)
	#get_tree().change_scene_to_file("res://game_over.tscn")  # ou autre scène
