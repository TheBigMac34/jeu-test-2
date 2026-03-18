extends Node2D

# --- VARIABLES D'ÉTAT ---
var CheckPoint_Manager # Référence au gestionnaire de checkpoints parent dans la scène
var last_location # Stocke la dernière position de respawn enregistrée par ce checkpoint

# --- RÉFÉRENCES AUX NŒUDS ---
@onready var sprite = $Area2D/AnimatedSprite2D # Référence au sprite animé du checkpoint (rouge/vert)
@onready var respawn_point = $RespownPoint # Référence au point de respawn associé à ce checkpoint

# --- INITIALISATION ---
func _ready() -> void:
	Global.load_checkpoint() # Charge la position de checkpoint sauvegardée depuis le fichier JSON
	CheckPoint_Manager = get_parent().get_node("CheckPoint Manager") # Récupère le nœud gestionnaire de checkpoints dans le parent

	# 🔁 RESTAURATION VISUELLE — remet le checkpoint en vert si c'est celui qui était actif à la dernière session
	if Global.last_checkpoint_position == respawn_point.global_position: # Compare la position sauvegardée avec celle de ce checkpoint
		sprite.play("Green") # Joue l'animation verte si ce checkpoint était le dernier actif
	else:
		sprite.play("Red") # Joue l'animation rouge si ce checkpoint n'est pas actif


# --- SIGNAL : ENTRÉE DANS LA ZONE ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Vérifie que c'est bien le joueur qui entre dans la zone
		if $Area2D/AnimatedSprite2D.animation == "Red": # Joue le son uniquement si le checkpoint n'était pas encore activé
			$AudioStreamPlayer.play() # Joue le son d'activation du checkpoint
		last_location = $RespownPoint.global_position # Récupère la position globale du point de respawn
		Global.last_checkpoint_position = last_location # Met à jour la position de checkpoint dans le singleton Global
		print("✅ Checkpoint sauvegardé :", last_location) # Affiche la position sauvegardée dans la console (debug)
		$Area2D/AnimatedSprite2D.play("Green") # Passe l'animation du checkpoint en vert pour indiquer qu'il est actif
		Global.save_checkpoint(respawn_point.global_position) # Sauvegarde la position de respawn dans le fichier JSON
