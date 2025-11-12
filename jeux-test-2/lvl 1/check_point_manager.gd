extends Node2D

var last_location: Vector2
var Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player = get_parent().get_node("Player")
	last_location = Player.global_position 
	Global.last_checkpoint_position = last_location


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
