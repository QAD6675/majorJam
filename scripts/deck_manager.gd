extends Node2D

var deck: Array[CardData] = []
var discard_pile: Array[CardData] = []

func _ready():
	load_cards_from_json("res://data/deck.tres")

func load_cards_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)	
	if not file:
		push_error("Failed to open deck.tres")
		return

	var json_text = file.get_as_text()
	var parsed = JSON.parse_string(json_text)
	
	if typeof(parsed) == TYPE_ARRAY:
		for card_data in parsed:
			var card = CardData.new()
			card.id = card_data.get("id", "")
			card.name = card_data.get("name", "")
			card.description = card_data.get("description", "")
			card.energy_cost = card_data.get("energy_cost", 0)
			card.type = card_data.get("type", "")
			card.target = card_data.get("target", "")
			card.effects = card_data.get("effects", [])
			deck.append(card)
	else:
		push_error("deck.json is not a valid array")

func get_card_by_id(card_id: String) -> CardData:
	for card in deck:
		if card.id == card_id:
			return card
	for card in discard_pile:
		if card.id == card_id:
			return card
	return null

func add_card(card_id: String) -> void:
	var card = get_card_by_id(card_id)
	if card:
		deck.append(card.duplicate())
	else:
		push_error("Card ID not found: " + card_id)

func remove_card(card_id: String) -> void:
	for i in range(deck.size()):
		if deck[i].id == card_id:
			deck.remove_at(i)
			return

func shuffle() -> void:
	deck.shuffle()

func draw_card() -> CardData:
	if len(deck)==0:
		reshuffle_discard_into_deck()
		if len(deck)==0:
			return null
	var card = deck.pop_front()
	discard_pile.append(card)
	return card

func discard_card(card: CardData) -> void:
	discard_pile.append(card)

func reshuffle_discard_into_deck() -> void:
	deck += discard_pile
	discard_pile.clear()
	deck.shuffle()

func get_deck() -> Array:
	return deck.duplicate()

func get_discard_pile() -> Array:
	return discard_pile.duplicate()

# Serialization for saving/loading
func serialize() -> Dictionary:
	var deck_data = []
	for card in deck:
		deck_data.append(card.id)
	var discard_data = []
	for card in discard_pile:
		discard_data.append(card.id)
	return {
		"deck": deck_data,
		"discard_pile": discard_data
	}

func deserialize(data: Dictionary) -> void:
	deck.clear()
	discard_pile.clear()
	if data.has("deck"):
		for card_id in data["deck"]:
			var card = get_card_by_id(card_id)
			if card:
				deck.append(card.duplicate())
	if data.has("discard_pile"):
		for card_id in data["discard_pile"]:
			var card = get_card_by_id(card_id)
			if card:
				discard_pile.append(card.duplicate())
