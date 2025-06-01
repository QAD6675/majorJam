extends Node2D

signal mapDone()
const map_PATH="res://data/map.json"

enum Biomes {Outskirsts,Slums,Ruins,City,Citadel}#in order
enum MapNode {Combat,Event}

@export var map:Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open(map_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) != TYPE_ARRAY:
			push_error("json stats is corrupted")
			return
		for biome in Biomes:
			for node in parsed[biome]:
				map.append({node.get("type"):node.get("enemies",[])})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
