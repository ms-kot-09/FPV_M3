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
		return {}
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		GLog.w("GI18n: JSON parse error")
		return {}
	if typeof(j.data) == TYPE_DICTIONARY:
		return j.data
	return {}
