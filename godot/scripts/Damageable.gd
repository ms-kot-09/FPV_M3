extends Node
class_name Damageable

signal died
signal damaged(amount: float)

@export var max_hp: float = 100.0
var hp: float

func _ready() -> void:
	hp = max_hp

func apply_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= max(amount, 0.0)
	emit_signal("damaged", amount)
	if hp <= 0.0:
		hp = 0.0
		emit_signal("died")
