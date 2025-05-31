extends Resource
class_name CardData

enum CardType {
	attack,
	spell
}

enum CardTarget {
	player,
	enemy,
	aoe,
}

enum CardEffect {
	damage,
	block,
	poison,
	weaken,
	buff_def,
	buff_dmg,
	draw,
	exauhst
}

@export var id: String
@export var name: String
@export var description: String
@export var energy_cost: int
@export var type: CardType
@export var target: CardTarget
@export var effects: Array[Dictionary]
