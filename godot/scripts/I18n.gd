extends Node
var dict: Dictionary = {}

func _ready() -> void:
	dict = _load_dict("res://data/i18n.json")

func tr_key(key: String) -> String:
	var lang: String = "en"
	if typeof(GSettings) != TYPE_NIL:
		lang = str(GSettings.language)
	if dict.has(key) and typeof(dict[key]) == TYPE_DICTIONARY:
		var row: Dictionary = dict[key] as Dictionary
		return str(row.get(lang, row.get("en", key)))
	return key

func _load_dict(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		GLog.w("GI18n: cannot open %s" % path)
		return {}
	var txt: String = f.get_as_text()
	var parsed_v: Variant = JSON.parse_string(txt)
	if typeof(parsed_v) != TYPE_DICTIONARY:
		GLog.w("GI18n: invalid JSON in %s" % path)
		return {}
	return parsed_v as Dictionary
