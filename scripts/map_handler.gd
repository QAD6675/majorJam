extends Node2D

signal mapDone(next_phase: game_state.Phase, enemy_ids: Array, event_data)
const map_PATH="res://data/map.json"

enum Biomes {Outskirsts,Slums,Ruins,City,Citadel}#in order
enum MapNode {Combat,Event}

@export var map:Array[Array]
@export var currentBiome:Biomes
@export var currentNode:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map.clear()
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
	currentBiome = Biomes.Outskirsts
	currentNode = 0

func get_current_node() -> Dictionary[MapNode,Array]:
	if currentBiome < map.size() and currentNode < map[currentBiome].size():
		return map[currentBiome][currentNode]
	return {}

func advance_node():
	currentNode += 1
	if currentBiome < map.size() and currentNode >= map[currentBiome].size():
		# End of biome, go to next biome
		currentBiome += 1
		currentNode = 0
	# Check end of map
	if currentBiome >= map.size():
		get_tree().change_scene_to_file("res://scenes/credits.tscn")
	emit_current_node()

func emit_current_node():
	var node = get_current_node()
	if node.is_empty():
		push_error("No map node at biome %d, node %d" % [currentBiome, currentNode])
		return
	match node.get(MapNode):
		MapNode.Combat:
			emit_signal("mapDone", %gameState.Phase.COMBAT, node.enemies, null)
		MapNode.Event:
			emit_signal("mapDone", %gameState.Phase.NONCOMBAT, [], node)
		_:
			push_error("Unknown node type: %s" % str(node.type))
