extends Node
class_name Settings

const PATH := "user://settings.json"

var language: String = "ru"
var master_volume: float = 0.9
var music_volume: float = 0.6
var sfx_volume: float = 0.9

var render_scale: float = 1.0
var shadows_enabled: bool = true
var fps_cap: int = 60
var fov: float = 90.0

# Touch layout (normalized 0..1 anchors for positions)
var touch_layout := {
	"left_stick": {"x": 0.16, "y": 0.78, "size": 1.0},
	"right_stick": {"x": 0.84, "y": 0.78, "size": 1.0}
}

func _ready() -> void:
	load_settings()
	apply()

func apply() -> void:
	# Graphics
	if Engine.has_singleton("DisplayServer"):
		# Render scale: use Viewport scaling for mobile-friendly perf
		ProjectSettings.set_setting("display/window/stretch/scale", render_scale)
	Engine.max_fps = fps_cap
	# FOV applied on camera at runtime
	# Audio
	_apply_audio()

func _apply_audio() -> void:
	if AudioServer.get_bus_index("Master") != -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

func to_dict() -> Dictionary:
	return {
		"language": language,
		"audio": {"master": master_volume, "music": music_volume, "sfx": sfx_volume},
		"graphics": {"render_scale": render_scale, "shadows": shadows_enabled, "fps_cap": fps_cap, "fov": fov},
		"touch_layout": touch_layout
	}

func from_dict(d: Dictionary) -> void:
	language = str(d.get("language", language))
	var a := d.get("audio", {})
	master_volume = float(a.get("master", master_volume))
	music_volume = float(a.get("music", music_volume))
	sfx_volume = float(a.get("sfx", sfx_volume))
	var g := d.get("graphics", {})
	render_scale = clamp(float(g.get("render_scale", render_scale)), 0.7, 1.0)
	shadows_enabled = bool(g.get("shadows", shadows_enabled))
	fps_cap = int(g.get("fps_cap", fps_cap))
	fov = clamp(float(g.get("fov", fov)), 60.0, 110.0)
	touch_layout = d.get("touch_layout", touch_layout)

func save_settings() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		Log.w("Settings: cannot write settings.json")
		return
	f.store_string(JSON.stringify(to_dict(), "\t"))

func load_settings() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var txt := f.get_as_text()
	var j := JSON.new()
	if j.parse(txt) != OK:
		Log.w("Settings: invalid JSON, ignoring")
		return
	var d := j.data
	if typeof(d) == TYPE_DICTIONARY:
		from_dict(d)
