extends Area3D
class_name Rocket

@export var speed: float = 55.0
@export var life: float = 3.0
@export var blast_radius: float = 5.0
@export var blast_damage: float = 120.0

var _t: float = 0.0
var _exploded: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_t += delta
	if _t >= life:
		_explode()
		return
	global_position += -global_transform.basis.z * speed * delta

func _on_body_entered(_body: Node) -> void:
	_explode()

func _explode() -> void:
	if _exploded:
		return
	_exploded = true
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
