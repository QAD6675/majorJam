extends Resource
class_name EnemyData

@export var id: String
@export var name: String
@export var max_hp: int
@export var current_hp: int
@export var intents: Array[Dictionary] = [] # Intent,value
@export var intent_index: int = 0
@export var status_effects: Dictionary = {}
@export var dmg_buff :=0
@export var poison :=0

enum Intent {attack,block,inflict,heal,buff}

func get_next_intent() -> Dictionary:
	if intents.is_empty():
		print("enemy peaceful")
		return {}
	if intent_index>=len(intents):
		intent_index=0
	var intent = intents[intent_index]
	intent_index += 1
	return intent

func take_damage(amount: int):
	current_hp = max(current_hp - amount, 0)
	if current_hp<=0:
		die()

func die():
	pass
