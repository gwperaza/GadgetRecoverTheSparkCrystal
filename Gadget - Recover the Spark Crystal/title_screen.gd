extends Camera2D

var function = 0

func _ready() -> void:
	$Label.hide()
	
func _process(delta: float) -> void:
	position.x += 1


func _on_texture_button_pressed() -> void:
	if function == 0:
		function = 1
		$title_screen.texture = null
		$title_screen/TextureButton.position.x += 400
		$Label.show()
	else:
		get_tree().change_scene_to_file("res://level.tscn")
