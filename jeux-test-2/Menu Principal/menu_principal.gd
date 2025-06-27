extends Control

@onready var first_level = preload("res://lvl 1/lvl_1_1.tscn")


func _ready() -> void:
	$"Chose your level".show()
	$"Main Menu".show()
	$back.hide()
	$"Level 1".hide()
	$"Level 1/VBoxContainer".hide()


func _on_chose_your_level_pressed() -> void:
	print("test")
	$"Chose your level".hide()
	$"Main Menu".hide()
	$back.show()
	$"Level 1".show()


func _on_back_pressed() -> void:
	$"Chose your level".show()
	$"Main Menu".show()
	$back.hide()
	$"Level 1".hide()
	$"Level 1/VBoxContainer".hide()

func _on_level_1_pressed() -> void:
	var box = $"Level 1/VBoxContainer"
	box.visible = not box.visible

func _on_level_11_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)
