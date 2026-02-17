extends Control

@onready var Bronze_Médaille = $"CenterContainer/HBoxContainer/Bronze/Bronze_Médaille"
@onready var Argent_Médaille = $"CenterContainer/HBoxContainer/Argent/Argent_Médaille"
@onready var Or_Médaille = $"CenterContainer/HBoxContainer/Or/Or_Médaille"


var menu_principale = preload("res://Menu/menu_principal.tscn")
var Bronze = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076.png")
var Argent = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0077.png")
var Or = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0078.png")
var Pointiller = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.medaille_bronze:
		Bronze_Médaille.texture = Bronze
	else:
		Bronze_Médaille.texture = Pointiller
	if Global.medaille_argent :
		Argent_Médaille.texture = Argent
	else:
		Argent_Médaille.texture = Pointiller
	if Global.medaille_or :
		Or_Médaille.texture = Or
	else:
		Or_Médaille.texture = Pointiller

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	Global.clear_checkpoint()
	get_tree().change_scene_to_packed(menu_principale)
	Global.last_checkpoint_position = Vector2.ZERO
	Global.coins = 0 
