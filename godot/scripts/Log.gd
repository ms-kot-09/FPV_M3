extends Node
enum Level { ERROR=0, WARN=1, INFO=2, DEBUG=3 }

var level: int = Level.INFO

func set_level(l: int) -> void:
	level = clamp(l, Level.ERROR, Level.DEBUG)

func e(msg: String) -> void:
	if level >= Level.ERROR:
		push_error(msg)

func w(msg: String) -> void:
	if level >= Level.WARN:
		push_warning(msg)

func i(msg: String) -> void:
	if level >= Level.INFO:
		print(msg)

func d(msg: String) -> void:
	if level >= Level.DEBUG:
		print("[D] ", msg)
