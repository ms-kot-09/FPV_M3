extends Node
const PATH := "user://settings.json"

# Language: "ru", "uk", "en"
var language: String = "en"

# Audio
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.9

# Graphics
var quality: String = "high" # low/med/high
var shadows: bool = true
var render_scale: float = 1.0 # 0.7..1.0
var fps_cap: int = 60
var fov: float = 85.0

func _ready() -> void:
	load()

func to_dict() -> Dictionary:
	return {
		"language": language,
		"audio": {
			"master": master_volume,
			"music": music_volume,
			"sfx": sfx_volume,
		},
		"graphics": {
			"quality": quality,
			"shadows": shadows,
			"render_scale": render_scale,
			"fps_cap": fps_cap,
			"fov": fov,
		},
	}

func from_dict(d: Dictionary) -> void:
	language = str(d.get("language", language))

	var a_any: Variant = d.get("audio", {})
	var a: Dictionary = a_any if typeof(a_any) == TYPE_DICTIONARY else {}
	master_volume = float(a.get("master", master_volume))
	music_volume = float(a.get("music", music_volume))
	sfx_volume = float(a.get("sfx", sfx_volume))

	var g_any: Variant = d.get("graphics", {})
	var g: Dictionary = g_any if typeof(g_any) == TYPE_DICTIONARY else {}
	quality = str(g.get("quality", quality))
	shadows = bool(g.get("shadows", shadows))
	render_scale = clamp(float(g.get("render_scale", render_scale)), 0.7, 1.0)

	var cap_val := int(g.get("fps_cap", fps_cap))
	if cap_val != 30 and cap_val != 60 and cap_val != 90:
		cap_val = 60
	fps_cap = cap_val

	fov = clamp(float(g.get("fov", fov)), 60.0, 110.0)

func load() -> void:
	if not FileAccess.file_exists(PATH):
		save()
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		GLog.w("GSettings: cannot open %s" % PATH)
		return
	var txt := f.get_as_text()
	var parsed := JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		GLog.w("GSettings: invalid JSON in %s" % PATH)
		return
	from_dict(parsed as Dictionary)

func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		GLog.w("GSettings: cannot write %s" % PATH)
		return
	f.store_string(JSON.stringify(to_dict(), "\t"))
