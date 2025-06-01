extends ResourcePreloader

signal stats_changed(stats:Dictionary[Stat,int])

const stats_PATH="res://data/stats.json"

enum Stat {max_hp,current_hp,gold}

@export var stats :={Stat.max_hp:100,
					Stat.current_hp:100,
					Stat.gold:0,
					}

func _ready() -> void:
	var file = FileAccess.open(stats_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(parsed) != TYPE_DICTIONARY:
			push_error("json stats is corrupted")
			return
		stats.set(Stat.max_hp,parsed.get(Stat.max_hp))
		stats.set(Stat.current_hp,parsed.get(Stat.current_hp))
		stats.set(Stat.gold,parsed.get(Stat.gold))
	emit_signal("stats_changed", stats)

func set_stats(new_stats: Dictionary[Stat,int]):
	stats=new_stats.duplicate()
	emit_signal("stats_changed", stats)

func gain_gold(amount: int):
	stats.set(Stat.gold, stats.get(Stat.gold)+amount)
	emit_signal("stats_changed",stats)

func heal(amount: int):
	stats.set(Stat.current_hp,min(stats.get(Stat.current_hp) +amount, stats.get(Stat.max_hp)))
	emit_signal("stats_changed",stats)

func hp_upgrade(amount:int):
	stats.set(Stat.max_hp,stats.get(Stat.max_hp)+amount)
	emit_signal("stats_changed",stats)

func _on_game_state_save() -> void:
	var stats = FileAccess.open(stats_PATH, FileAccess.WRITE)
	if not stats:
		push_error("Could not open stats JSON file: %s" %  stats_PATH)
		return
	stats.store_string(JSON.stringify(stats))
	stats.close()
	return
