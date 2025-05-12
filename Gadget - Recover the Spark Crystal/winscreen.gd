extends Camera2D

var function = 0

func _process(delta: float) -> void:
	position.x += 1

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")
