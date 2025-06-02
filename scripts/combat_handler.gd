extends Node2D

signal combat_ended(victory: bool)
signal card_play_failed()
signal card_play_success(index:int)

enum Turn { PLAYER, ENEMIES }

@export var energy:int =3
@export var enemies: Array[Resource] = []

var current_turn : Turn = Turn.PLAYER
@export var enemy_db := preload("res://data/enemies.json")

func start_combat(enemy_ids: Array):
	enemies.clear()
	for id in enemy_ids:
		if enemy_db.has(id):
			enemies.append(enemy_db[id].duplicate())
		else:
			push_error("Enemy id not found: %s" % id)
	energy = 3
	current_turn = Turn.PLAYER

func _on_deck_manager_try_play_card(card:CardData,target_index:int=0):
	if card.energy_cost>energy:
		emit_signal("card_play_failed")
		return
	energy-=card.energy_cost
	if target_index >= 0 and target_index < enemies.size():
		match card.CardTarget:
			CardData.CardTarget.enemy:
				var target = enemies[target_index]
				for effect in card.effects:
					match effect:
						CardData.CardEffect.damage:
							target.take_damage(card.effects.get(effect))
						CardData.CardEffect.poison:
							target.poison+=card.effects.get(effect)
						CardData.CardEffect.weaken:
							target.dmg_buff-=card.effects.get(effect)
			CardData.CardTarget.aoe:
				for effect in card.effects:
					match effect:
						CardData.CardEffect.damage:
							for target in enemies:
								target.take_damage(card.effects.get(effect))
						CardData.CardEffect.poison:
							for target in enemies:
								target.poison+=card.effects.get(effect)
						CardData.CardEffect.weaken:
							for target in enemies:
								target.dmg_buff-=card.effects.get(effect)
			CardData.CardTarget.player:
				for effect in card.effects:
					match effect:
						CardData.CardEffect.block:
							%"gameState/playerStats".block+=card.effects.get(effect)
						CardData.CardEffect.buff_def:
							%gameState/playerStats.def_buff+=card.effects.get(effect)
						CardData.CardEffect.buff_dmg:
							%gameState/playerStats.dmg_buff+=card.effects.get(effect)
						CardData.CardEffect.draw:
							for i in card.effects.get(effect):
								%gameState/deckManager.draw()
						CardData.CardEffect.exauhst:
							%cardZone.exauhstCard()
	emit_signal("card_play_success")
	enemies = enemies.filter(func(e): return e.current_hp > 0)
	if enemies.size() == 0:
		emit_signal("combat_ended", true)
	else:
		next_turn()
		
func next_turn():
	if current_turn == Turn.PLAYER:
		current_turn = Turn.ENEMIES
		emit_signal("turn_changed", current_turn)
		process_enemy_turns()
	else:
		current_turn = Turn.PLAYER
		energy = 3
		emit_signal("turn_changed", current_turn)

func process_enemy_turns():
	for enemy in enemies:
		var intent = enemy.get_next_intent()
		match intent.type:
			EnemyData.Intent.attack:
				%gameState/playerStats.take_damage(enemy.get(intent))
			EnemyData.Intent.block:
				enemy.block =enemy.get(intent)
			EnemyData.Intent.inflict:
				match enemy.get(intent):
					EnemyData.Inflictions.vulnerable:
						%gameState/playerStats.def_buff-=enemy.get(intent).get(EnemyData.Inflictions.vulnerable)
					EnemyData.Inflictions.poison:
						%gameState/playerStats.poison-=enemy.get(intent).get(EnemyData.Inflictions.poison)
					EnemyData.Inflictions.weaken:
						%gameState/playerStats.dmg_buff-=enemy.get(intent).get(EnemyData.Inflictions.weaken)
			EnemyData.Intent.heal:
				enemy.heal(enemy.get(intent))
			EnemyData.Intent.buff:
				enemy.dmg_buff+=enemy.get(intent)
		next_turn()
		
func _on_end_turn_pressed() -> void:
	current_turn=Turn.ENEMIES
	emit_signal("turnChanged",current_turn)
