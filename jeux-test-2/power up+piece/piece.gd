extends Node2D

# --- VARIABLES D'ÉTAT ---
var piece_recup = true # Vrai si la pièce est encore disponible à la collecte (empêche les doubles collectes)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# --- COLLECTE DE LA PIÈCE PAR LE JOUEUR ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and piece_recup: # Agit seulement si c'est le joueur ET que la pièce n'a pas encore été ramassée
		piece_recup = false # Marque la pièce comme déjà ramassée pour éviter un double comptage
		Global.coins += 1  # Ajoute 1 pièce au compteur global de pièces du joueur
		$AudioStreamPlayer.play() # Lance le son de collecte de la pièce
		$Area2D/AnimatedSprite2D.visible = false # Cache le sprite de la pièce immédiatement
		$Area2D.monitoring = false # Désactive la détection de collision pour éviter tout autre déclenchement
		await $AudioStreamPlayer.finished # Attend la fin du son avant de supprimer le nœud
		queue_free() # Supprime la pièce de la scène une fois le son terminé
