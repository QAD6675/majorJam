extends Node2D
#handles cards ui
#ONLY

signal playCardFromHand(cardIndex:int,target:int)#TODO add target here and connect to combat
signal exauhstCard(cardIndex:int)


func _on_deck_manager_card_drawn() -> void:
	pass # TODO animation


func _on_deck_manager_card_discarded(cardIndex: int) -> void:
	pass # TODO animation
