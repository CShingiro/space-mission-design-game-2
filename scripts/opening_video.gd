extends VideoStreamPlayer

func _ready() -> void:
	$RichTextLabel.show()
	await get_tree().create_timer(1.0).timeout
	$RichTextLabel.hide()

func _on_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
