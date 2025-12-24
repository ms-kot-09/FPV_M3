extends Node3D
class_name EnemyVehicle

@export var fire_range: float = 55.0
@export var fire_cooldown: float = 1.2
@export var damage: float = 18.0

var target: Node3D
var _cd: float = 0.0

@onready var dmg: Damageable = $Damageable

func _ready() -> void:
	dmg.died.connect(func(): queue_free())

func _process(delta: float) -> void:
	_cd = max(0.0, _cd - delta)
	if target == null or not is_instance_valid(target):
		return
	var dist := global_position.distance_to(target.global_position)
	look_at(target.global_position, Vector3.UP)
	if dist <= fire_range and _cd <= 0.0:
		_fire()
		_cd = fire_cooldown

func _fire() -> void:
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 1.2
	var to := target.global_position
	var res := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	if res.has("collider") and res["collider"] == target:
		if target.has_method("apply_damage"):
			target.call("apply_damage", damage)
