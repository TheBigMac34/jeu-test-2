extends Control

@onready var label := $Label
var camera: Camera2D = null

func _ready():
	# Attendre 1 frame pour être sûr que le Player est instancié
	await get_tree().process_frame

	# Trouver dynamiquement la Camera2D dans le Player instancié
	var player = get_parent().get_node_or_null("Player")
	if player:
		camera = player.get_node_or_null("Camera2D")

func _process(_delta):
	if camera:
		var screen_size = get_viewport_rect().size
		var center = camera.get_screen_center_position()

		# Position du coin haut-droit avec une petite marge
		var offset = Vector2(20, 20)
		label.global_position = center + Vector2(screen_size.x / 2, -screen_size.y / 2) - offset
