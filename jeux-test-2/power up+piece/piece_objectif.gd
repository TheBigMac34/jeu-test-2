extends Area2D

@export var level_id: String = "Lvl_1_1"
@export var piece_objectif_id: String = "piece_objectif_1"   # ex: "piece_objectif1", "piece_objectif2"...
@onready var collision := $CollisionShape2D
@onready var collect := $AudioStreamPlayer
@onready var sprite := $AnimatedSprite2D
signal collected

var save_path = "user://savegame.json"
var data: Dictionary = {}   # ✅ AJOUTE ÇA ICI
var piece_objectif := {}
var levels_data := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_state_from_save()


func _apply_state_from_save() -> void:
	var raw = Global.data.get("piece_objectif", {}).get(level_id, {}).get(piece_objectif_id, "MISSING")
	print("RAW=", raw, " TYPE=", typeof(raw))
	var done := Global.is_piece_objectif_collected(level_id, piece_objectif_id)
	visible = true  # <- garantit que la pièce ne soit pas "disparue"
	if done:
		# Déjà récupérée -> anim + plus de collision
		sprite.play("piece recup")
		collision.set_deferred("disabled", true)
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		print("deja recup")
	else:
		# Pas récupérée -> elle DOIT être là
		sprite.play("default")  # <- mets ici l'anim qui montre la pièce
		collision.set_deferred("disabled", false)
		set_deferred("monitoring", true)
		set_deferred("monitorable", true)
		print("pas recup")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	if Global.is_piece_objectif_collected(level_id, piece_objectif_id):
		return

	# sauvegarde
	Global.set_piece_objectif_collected(level_id, piece_objectif_id)
	emit_signal("collected")

	# feedback + désactivation
	if collect: collect.play()
	if sprite: sprite.play("piece recup")
	if collision: collision.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
