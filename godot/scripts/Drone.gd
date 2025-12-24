extends RigidBody3D
class_name Drone

signal fired
signal exploded

@export var max_hp: float = 100.0
@export var is_kamikaze: bool = false
@export var blast_radius: float = 6.0
@export var blast_damage: float = 140.0
@export var weapon_mode: String = "smg" # smg|rifle|shotgun|sniper|rocket|minigun|laser

@export var thrust: float = 32.0
@export var torque: float = 8.0
@export var drag_linear: float = 0.18
@export var drag_angular: float = 0.18

var hp: float
var input_throttle: float = 0.0 # -1..1
var input_yaw: float = 0.0      # -1..1
var input_pitch: float = 0.0    # -1..1
var input_roll: float = 0.0     # -1..1
var input_fire: bool = false
var input_boost: bool = false

var _cooldown: float = 0.0

func _ready() -> void:
	hp = max_hp
	linear_damp = drag_linear
	angular_damp = drag_angular
	continuous_cd = true

func set_inputs(throttle: float, yaw: float, pitch: float, roll: float, fire: bool, boost: bool) -> void:
	input_throttle = clamp(throttle, -1.0, 1.0)
	input_yaw = clamp(yaw, -1.0, 1.0)
	input_pitch = clamp(pitch, -1.0, 1.0)
	input_roll = clamp(roll, -1.0, 1.0)
	input_fire = fire
	input_boost = boost

func _physics_process(delta: float) -> void:
	# Throttle along local -Z (forward). In FPV, throttle controls up/down too, but this is simplified.
	var boost_mul := 1.6 if input_boost else 1.0
	apply_central_force(-global_transform.basis.z * thrust * input_throttle * boost_mul)
	# Torque: yaw around Y, pitch around X, roll around Z
	apply_torque(global_transform.basis.y * torque * input_yaw)
	apply_torque(global_transform.basis.x * torque * input_pitch)
	apply_torque(global_transform.basis.z * torque * -input_roll)

	# Weapon / kamikaze
	_cooldown = max(0.0, _cooldown - delta)
	if input_fire:
		if is_kamikaze:
			explode()
		elif _cooldown <= 0.0:
			_fire_weapon()

func _fire_weapon() -> void:
	emit_signal("fired")
	match weapon_mode:
		"sniper": _cooldown = 0.65
		"shotgun": _cooldown = 0.55
		"rocket": _cooldown = 0.9
		"minigun": _cooldown = 0.06
		"laser": _cooldown = 0.12
		_: _cooldown = 0.12

func apply_damage(amount: float) -> void:
	hp -= max(0.0, amount)
	if hp <= 0.0:
		explode()

func explode() -> void:
	if hp <= -999.0:
		return
	hp = -999.0
	emit_signal("exploded")
	# Damage everything with Damageable within radius
	var space := get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	var shape := SphereShape3D.new()
	shape.radius = blast_radius
	query.shape = shape
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hits := space.intersect_shape(query, 64)
	for h in hits:
		var col = h.get("collider")
		if col == null:
			continue
		var dmg := col.get_node_or_null("Damageable")
		if dmg and dmg is Damageable:
			(dmg as Damageable).apply_damage(blast_damage)
	queue_free()
