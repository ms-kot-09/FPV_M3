extends Control
class_name VirtualStick

signal moved(vec: Vector2)

@export var radius: float = 120.0
@export var deadzone: float = 0.08

var _center := Vector2.ZERO
var _value := Vector2.ZERO
var _dragging := false

func _ready() -> void:
	_center = size * 0.5
	set_process_input(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_center = size * 0.5

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and get_global_rect().has_point(event.position):
			_dragging = true
		elif not event.pressed and _dragging:
			_dragging = false
			_value = Vector2.ZERO
			emit_signal("moved", _value)
	elif event is InputEventScreenDrag and _dragging:
		var local_p := (event.position - global_position) - _center
		local_p = local_p.clamped(radius)
		_value = local_p / radius
		if _value.length() < deadzone:
			_value = Vector2.ZERO
		emit_signal("moved", _value)
