extends Sprite2D

func _on_coin_area_entered(area: Area2D) -> void:
	queue_free()
