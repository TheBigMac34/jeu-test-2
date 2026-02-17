extends CharacterBody2D

@export var speed := 60
@export var group_to_activate: String
@export var leader_chaine_de_4 := false
@export var leader_chaine_de_4v2 := false

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
	
	var is_leader := leader_chaine_de_4 or leader_chaine_de_4v2
	if not is_leader:
		return  # ⛔ seul un leader active le groupe
		

	if group_to_activate.strip_edges() == "":
		# print("⚠️ group_to_activate vide sur", name)
		return

	var mobs := get_tree().get_nodes_in_group(group_to_activate)
	# print("Leader", name, "active", mobs.size(), "mobs du groupe", group_to_activate)

	for mob in mobs:
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
		# print("hit chenille bleu")
