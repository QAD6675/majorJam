extends Button
var firstTime :=true

func _on_pressed() -> void:
	if firstTime:
		$"../title".text="come on at least try it"
		firstTime=false
	else:
		get_tree().quit()
