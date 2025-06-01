extends Node2D
#handles cards ui
#ONLY

signal playCardFromHand(cardIndex:int,target:int)#TODO add target here and connect to combat
signal exauhstCard(cardIndex:int)

func discard(Index:int):
	pass

func draw(card:CardData):
	pass

func shuffle():
	pass

func error():#when cant play card
	pass
