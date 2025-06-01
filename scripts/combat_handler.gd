extends Node2D

signal combat_ended(victory: bool)
signal turn_changed(turn: int) # 0=player, 1=enemies
signal card_play_failed()
signal card_play_success(index:int)

enum Turn { PLAYER, ENEMIES }

@export var energy:int =3
@export var enemies: Array[Resource] = []

var current_turn : Turn = Turn.PLAYER

func start_combat(enemy_datas: Array = []):
	# Clear any existing enemies
	enemies.clear()
	# Use provided enemy datas or sample from pool
	if enemy_datas.is_empty():
		push_error("no enemies")
		return
	else:
		for data in enemy_datas:
			enemies.append(data.duplicate())
	current_turn = Turn.PLAYER
	emit_signal("turn_changed", current_turn)
	# Optionally, update UI/enemy sprites here

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
	if enemies.size() == 0:
		emit_signal("combat_ended", true)

func next_turn():
	if current_turn == Turn.PLAYER:
		current_turn = Turn.ENEMIES
		emit_signal("turn_changed", current_turn)
		process_enemy_turns()
	else:
		current_turn = Turn.PLAYER
		emit_signal("turn_changed", current_turn)
		# Start player turn (draw cards, reset energy, etc.)

func process_enemy_turns():
	for i in enemies.size():
		var enemy = enemies[i]
		var intent = enemy.get_next_intent()
		match intent.get("type", ""):
			"attack":
				# Assume you have a reference to the player!
				get_node("/root/GameState/player_stats").take_damage(intent.get("value", 0))
			"block":
				enemy.status_effects["block"] = intent.get("value", 0)
			# Add more intent types as needed
	# End of enemy turn
	if player_is_dead():
		emit_signal("combat_ended", false, [])
	else:
		next_turn()

func player_is_dead() -> bool:
	var player_stats = get_node("/root/GameState/player_stats")
	return player_stats.stats[player_stats.Stat.current_hp] <= 0

func _on_game_state_phase_changed(new_phase: Variant) -> void:
	if new_phase==%gameState.Phase.COMBAT:
		start_combat()

func _on_end_turn_pressed() -> void:
	current_turn=Turn.ENEMIES
	emit_signal("turnChanged",current_turn)
