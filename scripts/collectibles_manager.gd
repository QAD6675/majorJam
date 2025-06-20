extends Node2D

@export var collectibles: Array[String] = []

func gain(collectible_id: String):
	if not collectibles.has(collectible_id):
		collectibles.append(collectible_id)
 
const collectibles_PATH="res://data/collectibles.json"

func _on_game_state_save() -> void:
	var collectibles = FileAccess.open(collectibles_PATH, FileAccess.WRITE)
	if not collectibles:
		push_error("Could not open collectibles JSON file: %s" % collectibles_PATH)
		return
	collectibles.store_string(JSON.stringify(collectibles))
	collectibles.close()
	return

func _ready() -> void:
	var file = FileAccess.open(collectibles_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) == TYPE_ARRAY:
			collectibles = parsed.duplicate()
		else :
			push_error("json collectibles corrupted")
