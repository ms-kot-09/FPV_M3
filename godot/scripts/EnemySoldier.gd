extends CharacterBody3D
class_name EnemySoldier

@export var move_speed: float = 5.0
@export var fire_range: float = 35.0
@export var fire_cooldown: float = 0.6
@export var damage: float = 8.0

var target: Node3D
var _cd: float = 0.0

@onready var dmg: Damageable = $Damageable

func _ready() -> void:
	dmg.died.connect(func(): queue_free())

func _physics_process(delta: float) -> void:
	_cd = max(0.0, _cd - delta)
	if target == null or not is_instance_valid(target):
		return
	var to_t := target.global_position - global_position
	to_t.y = 0.0
	var dist := to_t.length()
	if dist > 1.2:
		velocity = to_t.normalized() * move_speed
	else:
		velocity = Vector3.ZERO
	move_and_slide()
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	if dist <= fire_range and _cd <= 0.0:
		_fire_at_target()
		_cd = fire_cooldown

func _fire_at_target() -> void:
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 1.3
	var to := target.global_position
	var res := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 0b111111))
	if res.has("collider") and res["collider"] == target:
		if target.has_method("apply_damage"):
			target.call("apply_damage", damage)
