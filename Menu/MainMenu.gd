extends Control

onready var startgame_button = $MarginContainer/VBoxContainer/StartGame

func _ready() -> void:
	startgame_button.connect("pressed", self, "_on_startgame_button_pressed")

func _on_startgame_button_pressed() -> void:
	get_tree().change_scene("res://Stages/Stage_One.tscn")
