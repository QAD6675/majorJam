extends Node

var deck: Array[CardData] =[]

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
			card.effects = card_data.get("effects", {})

			deck[card.id] = card
	else:
		push_error("deck.json is not a valid array")

#func get_card_by_id(card_id: String) -> CardData:
	#return deck.find() card_id
