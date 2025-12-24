extends Node3D
class_name EnemySpawner

@export var spawn_soldiers: int = 8
@export var spawn_cars: int = 2
@export var spawn_tanks: int = 1
@export var radius: float = 45.0

@export var soldier_scene: PackedScene
@export var car_scene: PackedScene
@export var tank_scene: PackedScene

func spawn_all() -> void:
	_randomize()
	_spawn_many(soldier_scene, spawn_soldiers)
	_spawn_many(car_scene, spawn_cars)
	_spawn_many(tank_scene, spawn_tanks)

func _spawn_many(scene: PackedScene, count: int) -> void:
	if scene == null:
		return
	for i in range(count):
		var inst := scene.instantiate()
		add_child(inst)
		var a := randf() * TAU
		var r := sqrt(randf()) * radius
		inst.global_position = global_position + Vector3(cos(a)*r, 0.0, sin(a)*r)

func _randomize() -> void:
	if not Engine.is_editor_hint():
		randomize()
