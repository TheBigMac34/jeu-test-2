extends Control

# --- RÉFÉRENCES AUX NŒUDS DE MÉDAILLES ---
@onready var Bronze_Médaille = $"CenterContainer/HBoxContainer/Bronze/Bronze_Médaille" # Référence au TextureRect affichant la médaille bronze
@onready var Argent_Médaille = $"CenterContainer/HBoxContainer/Argent/Argent_Médaille" # Référence au TextureRect affichant la médaille argent
@onready var Or_Médaille = $"CenterContainer/HBoxContainer/Or/Or_Médaille" # Référence au TextureRect affichant la médaille or


# --- TEXTURES PRÉCHARGÉES ---
var menu_principale = preload("res://Menu/menu_principal.tscn") # Scène du menu principal préchargée pour la transition
var Bronze = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076.png") # Texture de la médaille bronze (obtenue)
var Argent = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0077.png") # Texture de la médaille argent (obtenue)
var Or = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0078.png") # Texture de la médaille or (obtenue)
var Pointiller = preload("res://base de donné image/kenney_platformer-art-pixel-redux/Tiles/tile_0076 pointiller.png") # Texture en pointillés pour les médailles non obtenues


# --- INITIALISATION ---
func _ready() -> void:
	# --- NAVIGATION MANETTE ---
	$Menu_Button.grab_focus() # donne le focus au bouton Menu dès l'affichage de l'écran de fin

	if Global.medaille_bronze: # Vérifie si la médaille bronze a été gagnée cette session
		Bronze_Médaille.texture = Bronze # Affiche la texture de médaille bronze obtenue
	else:
		Bronze_Médaille.texture = Pointiller # Affiche la texture en pointillés (médaille non obtenue)
	if Global.medaille_argent : # Vérifie si la médaille argent a été gagnée cette session
		Argent_Médaille.texture = Argent # Affiche la texture de médaille argent obtenue
	else:
		Argent_Médaille.texture = Pointiller # Affiche la texture en pointillés (médaille non obtenue)
	if Global.medaille_or : # Vérifie si la médaille or a été gagnée cette session
		Or_Médaille.texture = Or # Affiche la texture de médaille or obtenue
	else:
		Or_Médaille.texture = Pointiller # Affiche la texture en pointillés (médaille non obtenue)

# --- BOUCLE PRINCIPALE ---
func _process(delta: float) -> void:
	pass # Aucun traitement nécessaire chaque frame


# --- SIGNAL : BOUTON MENU PRESSÉ ---
func _on_menu_button_pressed() -> void:
	Global.clear_checkpoint() # Efface le checkpoint sauvegardé (le joueur repart du début)
	get_tree().change_scene_to_packed(menu_principale) # Change la scène vers le menu principal
	Global.last_checkpoint_position = Vector2.ZERO # Remet la position de checkpoint à zéro dans Global
	Global.coins = 0 # Remet le compteur de pièces à zéro pour la prochaine partie
