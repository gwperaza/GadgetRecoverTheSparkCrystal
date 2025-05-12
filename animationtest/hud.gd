extends Node

var lives

func _on_gadget_updatehud(updatelives, updatescore, updatecoins) -> void:
	lives = updatelives
	$ScoreVar.text = str(updatescore)
	$MarginContainer/VBoxContainer/HBoxContainer2/CoinVar.text = str(updatecoins)
