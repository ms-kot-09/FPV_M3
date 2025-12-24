extends Node
var dict: Dictionary = {}

func _ready() -> void:
	dict = _load_dict("res://data/i18n.json")

func tr_key(key: String) -> String:
	var lang: String = GSettings.language
	if dict.has(key) and typeof(dict[key]) == TYPE_DICTIONARY:
		var row: Dictionary = dict[key]
		return str(row.get(lang, row.get("en", key)))
	return key

func _load_dict(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		GLog.w("GI18n: missing %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		GLog.w("GI18n: cannot open %s" % path)
		return {}
	var parsed := JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		GLog.w("GI18n: invalid JSON in %s" % path)
		return {}
	return parsed as Dictionary
