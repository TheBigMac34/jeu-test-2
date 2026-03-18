extends CanvasLayer

# --- RESSOURCES PRÉCHARGÉES ---
@onready var menu_principale = preload("res://Menu/menu_principal.tscn") # Scène du menu principal préchargée pour la transition

# --- INITIALISATION ---
func _ready() -> void:
	$AudioStreamPlayer.play() # Joue la musique ou le son de l'écran Game Over au démarrage

	# --- NAVIGATION MANETTE ---
	$Button.focus_mode  = Control.FOCUS_ALL                          # autorise le focus sur le bouton Menu
	$Restart.focus_mode = Control.FOCUS_ALL                          # autorise le focus sur le bouton Retry
	$Button.focus_neighbor_bottom  = $Button.get_path_to($Restart)   # D-pad bas depuis Menu → Retry
	$Restart.focus_neighbor_top    = $Restart.get_path_to($Button)   # D-pad haut depuis Retry → Menu
	$Button.grab_focus()                                             # focus sur Menu au démarrage


# --- SIGNAL : BOUTON MENU PRESSÉ ---
func _on_button_pressed() -> void:
	Global.clear_checkpoint() # Efface le checkpoint sauvegardé (le joueur repart du début du niveau)
	get_tree().change_scene_to_packed(menu_principale) # Change la scène vers le menu principal
	Global.last_checkpoint_position = Vector2.ZERO # Remet la position de checkpoint à zéro dans Global
	Global.coins = 0 # Remet le compteur de pièces à zéro pour la prochaine partie


# --- SIGNAL : BOUTON RECOMMENCER PRESSÉ ---
func _on_restart_pressed() -> void:
	if Global.dernier_niveau_path != "": # Vérifie qu'un chemin de niveau a bien été enregistré
		get_tree().change_scene_to_file(Global.dernier_niveau_path) # Recharge le dernier niveau joué depuis son chemin de fichier
	else:
		print("Aucun niveau précédent enregistré.") # Affiche un message d'erreur si aucun niveau n'est mémorisé
	Global.vies_actuelles = 3 # Remet les vies du joueur à 3 pour recommencer le niveau
	Global.coins = 0 # Remet le compteur de pièces à zéro pour la nouvelle tentative
