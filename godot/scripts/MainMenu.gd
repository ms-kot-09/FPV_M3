extends Control

@export var drone_select_scene: PackedScene

@onready var play_btn: Button = $Root/Buttons/Play
@onready var coins_lbl: Label = $Root/Top/Coins

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	coins_lbl.text = "Coins: %d" % Save.coins

func _on_play() -> void:
	if drone_select_scene == null:
		Log.e("MainMenu: drone_select_scene not set")
		return
	get_tree().change_scene_to_packed(drone_select_scene)
