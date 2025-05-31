extends Node2D

var full_deck: Array[CardData] = []
var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []
var exhaust_pile: Array[CardData] = []
var hand: Array[CardData] = []
var hand_size := 6
@onready var card_zone: Node2D = %cardZone

func _ready():
	load_full_deck_from_tres("res://data/deck.tres")
	setup_combat_deck()

func load_full_deck_from_tres(path: String) -> void:
	var deck_resource = load(path)
	full_deck.clear()
	if deck_resource and deck_resource is Array:
		for card in deck_resource:
			if card is CardData:
				full_deck.append(card.duplicate())
			else:
				push_error("Invalid card in deck resource: not CardData")
	else:
		push_error("Failed to load deck.tres or resource is not an Array of CardData")

func setup_combat_deck() -> void:
	draw_pile.clear()
	discard_pile.clear()
	exhaust_pile.clear()
	hand.clear()
	for card in full_deck:
		draw_pile.append(card.duplicate())
	shuffle_draw_pile()

func shuffle_draw_pile() -> void:
	draw_pile.shuffle()

func draw_card() -> CardData:
	if hand.size() >= hand_size:
		push_warning("Hand limit reached!")
		return null
	if len(full_deck)==0:
		reshuffle_discard_into_draw_pile()
		if len(full_deck)==0:
			return null
	var card = draw_pile.pop_front()
	hand.append(card)
	return card

func discard_card(card: CardData) -> void:
	var idx = hand.find(card)
	if idx != -1:
		hand.remove_at(idx)
	discard_pile.append(card)

func exhaust_card(card: CardData) -> void:
	var idx = hand.find(card)
	if idx != -1:
		hand.remove_at(idx)
	exhaust_pile.append(card)

func play_card(card: CardData) -> void:
	var idx = hand.find(card)
	if idx != -1:
		hand.remove_at(idx)
		discard_pile.append(card)

func reshuffle_discard_into_draw_pile() -> void:
	draw_pile += discard_pile
	discard_pile.clear()
	shuffle_draw_pile()

func add_card(card: CardData) -> void:
	full_deck.append(card)
	draw_pile.append(card.duplicate())

func remove_card_by_id(card_id: String) -> void:
	for i in range(full_deck.size()):
		if full_deck[i].id == card_id:
			full_deck.remove_at(i)
			break

func get_full_deck() -> Array:
	return full_deck.duplicate()

func get_draw_pile() -> Array:
	return draw_pile.duplicate()

func get_discard_pile() -> Array:
	return discard_pile.duplicate()

func get_exhaust_pile() -> Array:
	return exhaust_pile.duplicate()

func get_hand() -> Array:
	return hand.duplicate()

# --- Helper: find card in full_deck by id ---
func find_in_full_deck(card_id: String) -> CardData:
	for card in full_deck:
		if card.id == card_id:
			return card
	return null

# --- Serialization for save/load ---
func serialize() -> Dictionary:
	var full_deck_ids = []
	for card in full_deck:
		full_deck_ids.append(card.id)
	var draw_pile_ids = []
	for card in draw_pile:
		draw_pile_ids.append(card.id)
	var discard_pile_ids = []
	for card in discard_pile:
		discard_pile_ids.append(card.id)
	var exhaust_pile_ids = []
	for card in exhaust_pile:
		exhaust_pile_ids.append(card.id)
	var hand_ids = []
	for card in hand:
		hand_ids.append(card.id)

	return {
		"full_deck": full_deck_ids,
		"draw_pile": draw_pile_ids,
		"discard_pile": discard_pile_ids,
		"exhaust_pile": exhaust_pile_ids,
		"hand": hand_ids
	}

func deserialize(data: Dictionary) -> void:
	full_deck.clear()
	draw_pile.clear()
	discard_pile.clear()
	exhaust_pile.clear()
	hand.clear()
	# Always load full_deck first
	if data.has("full_deck"):
		for card_id in data["full_deck"]:
			var card = find_in_full_deck(card_id)
			if card:
				full_deck.append(card.duplicate())
	# Now all piles can be restored from full_deck
	if data.has("draw_pile"):
		for card_id in data["draw_pile"]:
			var card = find_in_full_deck(card_id)
			if card:
				draw_pile.append(card.duplicate())
	if data.has("discard_pile"):
		for card_id in data["discard_pile"]:
			var card = find_in_full_deck(card_id)
			if card:
				discard_pile.append(card.duplicate())
	if data.has("exhaust_pile"):
		for card_id in data["exhaust_pile"]:
			var card = find_in_full_deck(card_id)
			if card:
				exhaust_pile.append(card.duplicate())
	if data.has("hand"):
		for card_id in data["hand"]:
			var card = find_in_full_deck(card_id)
			if card:
				hand.append(card.duplicate())
