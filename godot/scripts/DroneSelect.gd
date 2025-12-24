extends Control

@export var game_scene: PackedScene

@onready var list: OptionButton = $Root/Panel/VBox/DroneList
@onready var info: RichTextLabel = $Root/Panel/VBox/Info
@onready var start: Button = $Root/Panel/VBox/Start

func _ready() -> void:
	for d in GDataDB.drones:
		var id := str(d.get("id", ""))
		var name := str(d.get("name", id))
		list.add_item(name)
		list.set_item_metadata(list.item_count - 1, id)
	list.item_selected.connect(_on_selected)
	start.pressed.connect(_on_start)
	if list.item_count > 0:
		_on_selected(0)

func _on_selected(idx: int) -> void:
	var id := str(list.get_item_metadata(idx))
	GRun.selected_drone_id = id
	var d := GDataDB.get_drone_by_id(id)
	info.text = "[b]%s[/b]\nType: %s\nWeapon: %s" % [str(d.get("name", id)), str(d.get("type","")), str(d.get("weapon",""))]

func _on_start() -> void:
	if game_scene == null:
		GLog.e("DroneSelect: game_scene not set")
		return
	get_tree().change_scene_to_packed(game_scene)
