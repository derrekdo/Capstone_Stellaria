extends Node2D


onready var camera = $GameBoard/Camera2D
onready var mouse = $GameBoard/Cursor

var zoom = .1
var min_zoom = Vector2(1, 1)
var max_zoom = Vector2(4,4)
var cell := Vector2.ZERO

func _process(delta) -> void:
	camera.set_position(mouse.get_position())
