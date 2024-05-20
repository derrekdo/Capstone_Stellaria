extends Camera2D

var zoom_spd = 0.1
var min_zoom = 0.5
var max_zoom = 2.0

func _process(delta):
	if event is InputEventMouseMotion:
		if event.is_action("scroll_up"):
			zoom_in()
func zoom_in() -> void:
	var new_scale = clamp(get_parent().scale.x + 0.1, min_zoom, max_zoom)
	get_parent().scale = Vector2(new_scale, new_scale)

func zoom_out() -> void:
	var new_scale = clamp(get_parent().scale.x - 0.1, min_zoom, max_zoom)
	get_parent().scale = Vector2(new_scale, new_scale)
