extends Node
var drones: Array = []
var weapons: Array = []

func _ready() -> void:
	drones = _load_array_or_key("res://data/drones.json", "drones")
	weapons = _load_array_or_key("res://data/weapons.json", "weapons")
	GLog.i("GDataDB: drones=%d weapons=%d" % [drones.size(), weapons.size()])

func get_drone_by_id(id: String) -> Dictionary:
	for d in drones:
		if str(d.get("id", "")) == id:
			return d
	return {}

func _load_array_or_key(path: String, key: String) -> Array:
	if not FileAccess.file_exists(path):
		GLog.w("GDataDB: missing %s" % path)
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		GLog.w("GDataDB: JSON parse error %s" % path)
		return []
	if typeof(j.data) == TYPE_ARRAY:
		return j.data
	if typeof(j.data) == TYPE_DICTIONARY:
		var d: Dictionary = j.data
		if d.has(key) and typeof(d[key]) == TYPE_ARRAY:
			return d[key]
	return []
