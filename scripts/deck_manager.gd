extends Node2D

#signals
signal pilesChanged()

#consts
const DECK_PATH ="res://data/deck.json"
const CARDDB_PATH="res://data/cards.json"
# Deck and piles
var full_deck: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []
var hand: Array = []
var hand_limit := 6

func _ready():
	load_full_deck_from_json()
	setup_combat_deck()

# --- JSON Deck Loading ---
func load_full_deck_from_json() -> void:
	var deck = FileAccess.open(DECK_PATH, FileAccess.READ)
	var db = FileAccess.open(CARDDB_PATH, FileAccess.READ)
	if not deck:
		push_error("Could not open deck JSON file: %s" % DECK_PATH)
		return
	if not db:
		push_error("Could not open deck JSON file: %s" % CARDDB_PATH)
		return
	var parsed_deck = JSON.parse_string(deck.get_as_text())
	var parsed_db = JSON.parse_string(db.get_as_text())
	db.close()
	deck.close()
	if (typeof(parsed_db) != TYPE_ARRAY)or(typeof(parsed_deck) != TYPE_ARRAY):
		push_error("Deck or CardDB JSON root is not an array")
		return
	full_deck.clear()
	for owned_card in parsed_deck:
		for card_entry in parsed_db:
			if owned_card != card_entry.id:
				continue
			var card = CardData.new()
			card.id = card_entry.get("id", "")
			card.name = card_entry.get("name", "")
			card.description = card_entry.get("description", "")
			card.energy_cost = card_entry.get("energy_cost", 0)
			card.type = card_entry.get("type", "")
			card.target = card_entry.get("target", "")
			card.effects = card_entry.get("effects", {})
			full_deck.append(card)

# --- Setup at start of combat/encounter ---
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

# --- Card Drawing and Moving Logic ---
func draw_card() -> CardData:
	if hand.size() >= hand_limit:
		push_warning("Hand limit reached!")
		return null
	if len(draw_pile)==0:
		reshuffle_discard_into_draw_pile()
		if len(draw_pile)==0:
			push_warning("No Cards?")
			return null
	var card = draw_pile.pop_front()
	hand.append(card)
	return card

func discard_card(cardIndex: int) -> void:
	if cardIndex >= 0:
		discard_pile.append(draw_pile[cardIndex].duplicate())
		hand.remove_at(cardIndex)

func exhaust_card(cardIndex) -> void:
	if cardIndex >= 0:
		exhaust_pile.append(draw_pile[cardIndex].duplicate())
		hand.remove_at(cardIndex)

func play_card(cardIndex: int) -> void:
#	TODO:play it
	discard_card(cardIndex)

func reshuffle_discard_into_draw_pile() -> void:
	draw_pile += discard_pile
	discard_pile.clear()
	shuffle_draw_pile()

func add_card(card: CardData) -> void:
	full_deck.append(card)

func remove_card(cardIndex) -> void:
	full_deck.remove_at(cardIndex)

# --- Querying piles for UI or logic ---
func get_full_deck() -> Array:
	return full_deck

func get_draw_pile() -> Array:
	return draw_pile

func get_discard_pile() -> Array:
	return discard_pile

func get_exhaust_pile() -> Array:
	return exhaust_pile

func get_hand() -> Array:
	return hand

func get_card(cardIndex) -> CardData:
	return full_deck[cardIndex]

func serialize() -> Array:
	var full_deck_ids = []
	for card in full_deck:
		full_deck_ids.append(card.id)
	return full_deck_ids
	
func _on_game_state_save() -> void:
	var deck = FileAccess.open(DECK_PATH, FileAccess.WRITE)
	if not deck:
		push_error("Could not open deck JSON file: %s" % DECK_PATH)
		return
	deck.store_string(JSON.stringify(serialize()))
	deck.close()
	return

func find_in_deck(card_id: String,depth:int=1) -> Array[CardData]:
	var results :=[]
	for card in full_deck:
		if card.id == card_id and len(results)<depth:
			results.append(card)
		else:
			break
	return results
