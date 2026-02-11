extends CharacterBody2D

@export var speed := 60
@export var group_to_activate := "chainede4"
@export var leader_chaine_de_4 := false


var has_been_visible := false
var is_active := false

var direction := -1  # -1 = gauche, 1 = droite

const Y_LIMITE = 100  # Choisis une valeur assez basse selon ton niveau

func _ready():
	pass

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	has_been_visible = true
	is_active = true
	#print("entred screen")
	
	if not leader_chaine_de_4:
		return  # ⛔ seul le leader active le groupe
	
	for mob in get_tree().get_nodes_in_group(group_to_activate):
		mob.is_active = true



func _physics_process(delta):
	if not is_active:
		return
	
	if position.y > Y_LIMITE:
		queue_free()
		#print("MORT")
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = speed * direction
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):  
		body.take_damage()  
		print("hit chenille bleu")
