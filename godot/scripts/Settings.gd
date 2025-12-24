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
	load_settings()

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

	var audio_v: Variant = d.get("audio", {})
	if typeof(audio_v) == TYPE_DICTIONARY:
		var audio: Dictionary = audio_v as Dictionary
		master_volume = float(audio.get("master", master_volume))
		music_volume = float(audio.get("music", music_volume))
		sfx_volume = float(audio.get("sfx", sfx_volume))

	var g_v: Variant = d.get("graphics", {})
	if typeof(g_v) == TYPE_DICTIONARY:
		var g: Dictionary = g_v as Dictionary
		quality = str(g.get("quality", quality))
		shadows = bool(g.get("shadows", shadows))
		render_scale = clampf(float(g.get("render_scale", render_scale)), 0.7, 1.0)
		fps_cap = int(g.get("fps_cap", fps_cap))
		fov = clampf(float(g.get("fov", fov)), 60.0, 110.0)

	# normalize
	if quality not in ["low", "med", "high"]:
		quality = "high"
	fps_cap = maxi(30, fps_cap)

func load_settings() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		GLog.w("GSettings: cannot open %s" % PATH)
		return
	var txt: String = f.get_as_text()
	var parsed_v: Variant = JSON.parse_string(txt)
	if typeof(parsed_v) != TYPE_DICTIONARY:
		GLog.w("GSettings: invalid JSON in %s" % PATH)
		return
	from_dict(parsed_v as Dictionary)

func save_settings() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		GLog.w("GSettings: cannot write %s" % PATH)
		return
	f.store_string(JSON.stringify(to_dict(), "\t"))
