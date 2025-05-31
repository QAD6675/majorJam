extends Node2D

# --- Signals ---
signal phase_changed(new_phase)
signal node_advanced(node_phase, loop, node_index)
signal player_stats_changed(stats)
signal deck_changed(deck)
signal collectible_gained(item)
signal rewards_given(rewards)

# --- Enums ---
enum Phase { COMBAT, REWARD, MAP, NON_COMBAT }
enum Rewards { GOLD, CARD, COLLECTIBLE, HP }

# --- State ---
var phase := Phase.COMBAT
var current_loop: int = 1
var node_index: int = 0

# --- Children Managers (set up as children in the scene, NOT dynamically instanced) ---
@onready var player_stats: ResourcePreloader = $playerStats
@onready var deck_manager: Node2D = $deckManager
@onready var collectibles_manager: Node2D = $collectiblesManager

# --- Scene Handlers (set in the editor or via onready paths as needed) ---
@onready var map_handler: Node2D = %mapHandler
@onready var combat_handler: Node2D = %combatHandler
@onready var non_combat_handler: Node2D = %nonCombatHandler
@onready var rewards_handler: Node2D = %RewardsHandler

func _ready():
	connect_signals()
	start_game()

func connect_signals():
	if combat_handler and combat_handler.has_signal("combat_ended"):
		combat_handler.connect("combat_ended", Callable(self, "_on_combat_ended"))
	if rewards_handler and rewards_handler.has_signal("rewards_claimed"):
		rewards_handler.connect("rewards_claimed", Callable(self, "_on_rewards_claimed"))
	if map_handler and map_handler.has_signal("mapDone"):
		map_handler.connect("mapDone", Callable(self, "_on_map_done"))
	if non_combat_handler and non_combat_handler.has_signal("event_ended"):
		non_combat_handler.connect("event_ended", Callable(self, "_on_event_ended"))

func start_game():
	phase = Phase.COMBAT
	node_index = 0
	current_loop = 1
	enter_phase(Phase.COMBAT)

func enter_phase(new_phase: Phase, data = null):
	phase = new_phase
	emit_signal("phase_changed", phase)
	match phase:
		Phase.COMBAT:
			_show_handler(combat_handler)
			if combat_handler.has_method("start_combat"):
				combat_handler.start_combat(data)
		Phase.REWARD:
			_show_handler(rewards_handler)
			if rewards_handler.has_method("present_rewards"):
				rewards_handler.present_rewards(data)
		Phase.MAP:
			_show_handler(map_handler)
			if map_handler.has_method("display_map"):
				map_handler.display_map(current_loop, node_index)
		Phase.NON_COMBAT:
			_show_handler(non_combat_handler)
			if non_combat_handler.has_method("start_event"):
				non_combat_handler.start_event(data)
		_:
			push_warning("Unknown phase: %s" % str(phase))

func _show_handler(handler: Node):
	for h in [combat_handler, rewards_handler, map_handler, non_combat_handler]:
		if h: h.visible = (h == handler)

# --- FLOW EVENTS ---
func _on_combat_ended(victory: bool, reward_data = null):
	if victory:
		enter_phase(Phase.REWARD, reward_data)
	else:
		game_over()

func _on_rewards_claimed(rewards):
	collect_rewards(rewards)
	enter_phase(Phase.MAP)

func _on_map_done(next_phase: Phase, enemy_data = null, event_data = null):
	phase = next_phase
	node_index += 1
	emit_signal("node_advanced", phase, current_loop, node_index)
	match phase:
		Phase.COMBAT:
			enter_phase(Phase.COMBAT, enemy_data)
		Phase.NON_COMBAT:
			enter_phase(Phase.NON_COMBAT, event_data)
		_:
			push_warning("Unknown node type: %s" % str(phase))

func _on_event_ended():
	enter_phase(Phase.MAP)

func collect_rewards(rewards):
	for reward in rewards:
		match reward.type:
			Rewards.CARD:
				deck_manager.add_card(reward.card_id)
			Rewards.COLLECTIBLE:
				collectibles_manager.gain(reward.collectible_id)
			Rewards.GOLD:
				player_stats.gain_gold(reward.amount)
			Rewards.HP:
				player_stats.heal(reward.amount)
			_:
				push_warning("Unknown reward type: %s" % str(reward.type))
	emit_signal("rewards_given", rewards)

func game_over():
	# TODO: Implement game over logic here (show screen, save stats, etc.)
	pass

# --- LOOP MANAGEMENT ---
func advance_loop():
	current_loop += 1
	node_index = 0
	enter_phase(Phase.MAP)

# --- PLAYER/DECK INTERFACE ---
func update_player_stats(new_stats: Dictionary):
	if player_stats.has_method("set_stats"):
		player_stats.set_stats(new_stats)
		emit_signal("player_stats_changed", player_stats.get_stats())

func get_player_stats() -> Dictionary:
	if player_stats.has_method("get_stats"):
		return player_stats.get_stats()
	return {}

func get_deck() -> Array:
	if deck_manager.has_method("get_deck"):
		return deck_manager.get_deck()
	return []

func add_to_deck(card_id: String):
	if deck_manager.has_method("add_card"):
		deck_manager.add_card(card_id)
		emit_signal("deck_changed", deck_manager.get_deck())

func get_collectibles() -> Array:
	if collectibles_manager.has_method("get_all"):
		return collectibles_manager.get_all()
	return []

# --- (OPTIONAL) SAVE/LOAD ---
func save_game():
	var save_data = {
		"loop": current_loop,
		"node_index": node_index,
		"player_stats": player_stats.serialize() if player_stats.has_method("serialize") else {},
		"deck": deck_manager.serialize() if deck_manager.has_method("serialize") else {},
		"collectibles": collectibles_manager.serialize() if collectibles_manager.has_method("serialize") else {}
	}
	# Save to file logic here

func load_game(save_data: Dictionary):
	current_loop = save_data.get("loop", 1)
	node_index = save_data.get("node_index", 0)
	if player_stats.has_method("deserialize"):
		player_stats.deserialize(save_data.get("player_stats", {}))
	if deck_manager.has_method("deserialize"):
		deck_manager.deserialize(save_data.get("deck", {}))
	if collectibles_manager.has_method("deserialize"):
		collectibles_manager.deserialize(save_data.get("collectibles", {}))
	enter_phase(Phase.MAP)
