extends Node3D

@export var drone_scene: PackedScene
@export var rocket_scene: PackedScene

@onready var spawner: EnemySpawner = $EnemySpawner
@onready var hud: CanvasLayer = $HUD
@onready var touch: TouchHUD = $TouchHUD
@onready var cam_pivot: Node3D = $DroneSpawn/CameraPivot

var player: Drone
var kills: int = 0

func _ready() -> void:
	_spawn_drone()
	spawner.spawn_all()
	_assign_enemy_targets()
	if player:
		player.fired.connect(_on_player_fired)
		player.exploded.connect(_on_player_exploded)
	touch.input_changed.connect(_on_input_changed)
	_update_hud()

func _spawn_drone() -> void:
	if drone_scene == null:
		GLog.e("Game: drone_scene not set")
		return
	player = drone_scene.instantiate()
	add_child(player)
	player.global_position = $DroneSpawn.global_position
	# apply selected drone parameters from data
	var id := GRun.selected_drone_id
	var d := GDataDB.get_drone_by_id(id)
	var dtype := str(d.get("type", "armed"))
	player.is_kamikaze = (dtype == "kamikaze")
	player.blast_radius = float(d.get("blast_radius", player.blast_radius))
	player.blast_damage = float(d.get("damage", player.blast_damage))
	var w := str(d.get("weapon", player.weapon_mode))
	match w:
		"ar": player.weapon_mode = "rifle"
		"rockets", "missiles": player.weapon_mode = "rocket"
		"autocannon": player.weapon_mode = "minigun"
		_: player.weapon_mode = w
	player.max_hp = float(d.get("hp", player.max_hp))
	# speed/agility -> thrust/torque scaling
	var sp := float(d.get("speed", 1.0))
	var ag := float(d.get("agility", 1.0))
	player.thrust = player.thrust * sp
	player.torque = player.torque * ag
	# attach camera

	var cam := $DroneSpawn/CameraPivot/Camera3D
	cam.current = true
	cam.fov = GSettings.fov
	cam_pivot.reparent(player)
	cam_pivot.position = Vector3.ZERO

func _assign_enemy_targets() -> void:
	for c in spawner.get_children():
		if c.has_variable("target"):
			c.set("target", player)

func _on_input_changed(throttle: float, yaw: float, pitch: float, roll: float, fire: bool, boost: bool) -> void:
	if player and is_instance_valid(player):
		player.set_inputs(throttle, yaw, pitch, roll, fire, boost)

func _on_player_fired() -> void:
	if not player:
		return
	var cam := $DroneSpawn/CameraPivot/Camera3D
	match player.weapon_mode:
		"rocket":
			_fire_rocket(cam)
		"shotgun":
			_fire_hitscan(cam, 8, 3.0, 10.0)
		"sniper":
			_fire_hitscan(cam, 1, 0.3, 70.0)
		"laser":
			_fire_hitscan(cam, 1, 0.7, 22.0)
		"minigun":
			_fire_hitscan(cam, 1, 2.5, 6.0)
		"rifle":
			_fire_hitscan(cam, 1, 2.0, 12.0)
		_: # smg
			_fire_hitscan(cam, 1, 3.5, 9.0)

func _fire_hitscan(cam: Camera3D, pellets: int, spread_deg: float, dmg: float) -> void:
	var space := get_world_3d().direct_space_state
	for i in range(pellets):
		var dir := -cam.global_transform.basis.z
		# simple spread
		var yaw := deg_to_rad(randf_range(-spread_deg, spread_deg))
		var pit := deg_to_rad(randf_range(-spread_deg, spread_deg))
		var basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pit)
		dir = (basis * dir).normalized()
		var from := cam.global_position
		var to := from + dir * 200.0
		var res := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if res.has("collider"):
			var col = res["collider"]
			var dn = col.get_node_or_null("Damageable")
			if dn and dn is Damageable:
				(dn as Damageable).apply_damage(dmg)
				if (dn as Damageable).hp <= 0.0:
					kills += 1
					GSave.add_coins(5)
					_update_hud()

func _fire_rocket(cam: Camera3D) -> void:
	if rocket_scene == null:
		_fire_hitscan(cam, 1, 1.0, 30.0)
		return
	var r := rocket_scene.instantiate() as Rocket
	add_child(r)
	r.global_transform = cam.global_transform
	r.global_position = cam.global_position + -cam.global_transform.basis.z * 1.0

func _on_player_exploded() -> void:
	touch.set_info("Drone destroyed! Tap Fire to restart.")

func _update_hud() -> void:
	if hud.has_node("Root/Stats"):
		hud.get_node("Root/Stats").text = "Kills: %d  Coins: %d" % [kills, GSave.coins]
