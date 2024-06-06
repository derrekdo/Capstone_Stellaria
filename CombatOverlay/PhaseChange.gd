class_name PhaseChange
extends TextureRect

onready var anim_player := $AnimationPlayer
func _ready() -> void:
	pass # Replace with function body.

func set_phase_change(change: bool) -> void:
	if change:
		anim_player.play("Change_Phase")
	else:
		anim_player.play("idle")

