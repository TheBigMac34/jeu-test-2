extends Area2D

@export var soin := 1
@export var une_seule_fois := true

var deja_utilisee := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not deja_utilisee:
		for i in soin:
			Global.gagner_vie()
		if une_seule_fois:
			deja_utilisee = true
			queue_free() 
	var ui = get_tree().current_scene.get_node_or_null("ui")
	if ui:
		ui.update_vie()
	print("get heal")
