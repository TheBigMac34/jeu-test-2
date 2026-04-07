extends Node2D

# --- RÉFÉRENCES ---
@onready var bouton_a = $ColorRect/XboxButtonAOutline  # bouton A en bas à droite (animation breathing)

# --- PARAMÈTRES ---
const MENU_SCENE = "res://Menu/menu_principal.tscn"  # scène vers laquelle on transite après l'intro
const AUTO_SKIP_TIME = 6.0                            # secondes avant de passer automatiquement au menu

# --- VARIABLES ---
var timer_elapsed := 0.0   # temps écoulé depuis le début de l'intro
var peut_passer := false    # vrai une frame après le démarrage (évite un skip immédiat accidentel)


func _ready() -> void:
	_start_breathing()                     # lance l'animation de respiration sur le bouton A

	# Permet le skip une frame plus tard (évite de passer instantanément)
	await get_tree().process_frame         # attend une frame avant d'activer le skip
	peut_passer = true                     # active la détection d'appui


var breath_timer := 0.0  # compteur pour l'effet de respiration

func _start_breathing() -> void:
	pass  # l'animation se fait dans _process via breath_timer


func _process(delta: float) -> void:
	if not peut_passer:
		return                             # on ne fait rien avant la première frame

	timer_elapsed += delta                 # incrémente le temps écoulé

	# Animation breathing : scale oscille entre 1.0 et 1.25 via un sinus
	breath_timer += delta
	var s = 1.0 + 0.1 * sin(breath_timer * 3.0)   # oscille entre 1.0 et 1.10
	bouton_a.scale = Vector2(s, s)                 # applique le scale directement

	# Passage automatique après AUTO_SKIP_TIME secondes
	if timer_elapsed >= AUTO_SKIP_TIME:
		_aller_au_menu()
		return

	# Skip sur appui de n'importe quelle touche manette ou clavier
	if Input.is_action_just_pressed("ui_accept") or \
	   Input.is_action_just_pressed("ui_cancel") or \
	   Input.is_action_just_pressed("dash"):
		_aller_au_menu()


func _aller_au_menu() -> void:
	peut_passer = false  # empêche un double déclenchement
	get_tree().call_deferred("change_scene_to_file", MENU_SCENE)  # change vers le menu principal
