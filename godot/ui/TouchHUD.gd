extends CanvasLayer
class_name TouchHUD

signal input_changed(throttle: float, yaw: float, pitch: float, roll: float, fire: bool, boost: bool)

@onready var left: VirtualStick = $Root/LeftStick
@onready var right: VirtualStick = $Root/RightStick
@onready var fire_btn: Button = $Root/FireButton
@onready var boost_btn: Button = $Root/BoostButton
@onready var info_label: Label = $Root/Info

var _l := Vector2.ZERO
var _r := Vector2.ZERO
var _fire := false
var _boost := false

func _ready() -> void:
	left.moved.connect(func(v: Vector2): _l = v; _emit())
	right.moved.connect(func(v: Vector2): _r = v; _emit())
	fire_btn.button_down.connect(func(): _fire = true; _emit())
	fire_btn.button_up.connect(func(): _fire = false; _emit())
	boost_btn.button_down.connect(func(): _boost = true; _emit())
	boost_btn.button_up.connect(func(): _boost = false; _emit())

func set_info(text: String) -> void:
	info_label.text = text

func _emit() -> void:
	# FPV-ish: left stick Y = throttle, X = yaw. right stick Y = pitch, X = roll.
	var throttle := -_l.y
	var yaw := _l.x
	var pitch := -_r.y
	var roll := _r.x
	emit_signal("input_changed", throttle, yaw, pitch, roll, _fire, _boost)
