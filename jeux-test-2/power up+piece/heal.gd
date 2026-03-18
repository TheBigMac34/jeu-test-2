extends Area2D

# --- PARAMÈTRES EXPORTÉS ---
@export var soin := 1 # Nombre de vies restaurées à chaque utilisation du heal
@export var une_seule_fois := true # Si vrai, le heal ne peut être utilisé qu'une seule fois avant de disparaître

# --- VARIABLES D'ÉTAT ---
var deja_utilisee := false # Vrai si le heal a déjà été utilisé (évite les doubles soins)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# --- SOIN DU JOUEUR AU CONTACT ---
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not deja_utilisee: # Agit seulement si c'est le joueur ET que le heal n'a pas encore été utilisé
		for i in soin: # Boucle autant de fois que le nombre de soins configuré
			Global.gagner_vie() # Ajoute une vie via le singleton Global
		if une_seule_fois: # Si le heal est configuré pour n'être utilisé qu'une fois
			deja_utilisee = true # Marque le heal comme déjà utilisé
			queue_free()  # Supprime le heal de la scène après utilisation
	var ui = get_tree().current_scene.get_node_or_null("ui") # Récupère le nœud UI de la scène courante (s'il existe)
	if ui: # Vérifie que l'UI a bien été trouvé avant de l'utiliser
		ui.update_vie() # Met à jour l'affichage des vies dans l'interface
	print("get heal") # Message de debug indiquant que le heal a été ramassé
