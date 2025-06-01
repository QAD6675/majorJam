extends Node2D

#handles the combat phase

enum Turn {player,enemy}

var currentTurn:Turn

signal turnChanged(Turn)
signal combat_ended()

func _on_game_state_phase_changed(new_phase: Variant) -> void:
	if new_phase==%gameState.Phase.COMBAT:
		currentTurn=Turn.player
		emit_signal("turnChanged",currentTurn)


func _on_end_turn_pressed() -> void:
	currentTurn=Turn.enemy
	emit_signal("turnChanged",currentTurn)

func start_combat():
	pass
