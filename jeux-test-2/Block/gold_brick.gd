extends StaticBody2D

@export var cassable := true
@export var sprite_actif: Texture2D
@export var sprite_vide: Texture2D
@onready var sprite := $Sprite2D
@export var piece_scene: PackedScene

var active := true


func casser():
	if not active:
		return
	if cassable:
		active = false
		sprite.texture = sprite_vide
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y - 6, 0.05)
		tween.tween_property(self, "position:y", position.y, 0.05)
		
	if piece_scene:
		var piece = piece_scene.instantiate()
		get_tree().current_scene.add_child(piece)

		# ✅ on positionne AVANT
		piece.global_position = global_position + Vector2(0, -16)

		# ✅ puis on lance l’animation
		piece.start_animation()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
