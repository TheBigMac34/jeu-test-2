extends CanvasLayer

@onready var life_container = $LifeContainer  # ton HBoxContainer ou autre


func _ready() -> void:
	update_vie()

func _process(delta: float) -> void:
	pass

func update_vie():
	# Supprimer les icônes précédentes
	for child in life_container.get_children():
		child.queue_free()
	print("nonon")
	# Ajouter autant de vies que dans Global
	for i in Global.vies_actuelles:
		var coeur = TextureRect.new()
		coeur.texture = preload("res://base de donné image/kenney_pixel-platformer/Tiles/tile_0044.png")
		coeur.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		life_container.add_child(coeur)
