extends Control


func _ready() -> void:
	$"Chose your level".show()
	$"Main Menu".show()
	$back.hide()
	$"Level 1".hide()
	$"Level 1/VBoxContainer".hide()


func _on_chose_your_level_pressed() -> void:
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
