extends Node2D

var CheckPoint_Manager
var last_location


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CheckPoint_Manager = get_parent().get_node("CheckPoint Manager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		CheckPoint_Manager.last_location = $RespownPoint.global_position
		print("CP")
		last_location = $RespownPoint.global_position
		Global.last_checkpoint_position = last_location
		print("✅ Checkpoint sauvegardé :", last_location)
