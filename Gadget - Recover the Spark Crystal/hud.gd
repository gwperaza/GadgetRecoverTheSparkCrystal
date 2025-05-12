extends Node

var lives = 3

func _on_gadget_updatehud(updatelives, updatescore, updatecoins) -> void:
	lives = updatelives
	$ScoreVar.text = str(updatescore)
	$MarginContainer/VBoxContainer/HBoxContainer2/CoinVar.text = str(updatecoins)

func _process(delta: float) -> void:
	if lives < 3:
		$MarginContainer/VBoxContainer/HBoxContainer/L3.hide()
	if lives < 2:
		$MarginContainer/VBoxContainer/HBoxContainer/L2.hide()
