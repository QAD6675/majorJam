extends Resource
class_name CardData

enum CardType {
	ATTACK,
	SPELL
}

enum CardTarget {
	PLAYER,
	SINGLE_ENEMY,
	MULTIPLE_ENEMY,	
	AOE,
}

@export var id: String
@export var name: String
@export var description: String
@export var energy_cost: int
@export var type: int # Use CardType enum
@export var target: int # Use CardTarget enum
@export var effects: Dictionary
