extends Node

@export var main_menu_scene: PackedScene

func _ready() -> void:
	if main_menu_scene == null:
		Log.e("Bootstrap: main_menu_scene not set")
		return
	get_tree().change_scene_to_packed(main_menu_scene)
