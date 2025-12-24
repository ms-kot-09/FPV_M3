extends Node
const PATH := "user://save.json"

var coins: int = 0

func _ready() -> void:
	load_save()

func add_coins(amount: int) -> void:
	coins = max(0, coins + amount)
	save()

func to_dict() -> Dictionary:
	return {"coins": coins}

func from_dict(d: Dictionary) -> void:
	coins = max(0, int(d.get("coins", coins)))

func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		GLog.w("GSave: can't write save.json")
		return
	f.store_string(JSON.stringify(to_dict(), "\t"))

func load_save() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var txt := f.get_as_text()
	var j := JSON.new()
	if j.parse(txt) != OK:
		GLog.w("GSave: invalid JSON")
		return
	if typeof(j.data) == TYPE_DICTIONARY:
		from_dict(j.data)
