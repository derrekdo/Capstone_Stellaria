extends PopupMenu

signal attack_selected
signal inventory_selected
signal recruit_selected
signal wait_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#make dynamic, only appears when available 
	add_item("Attack", 0)
	add_item("Inventory", 1)
	add_item("Recruit", 2)
	#permanent option
	add_item("Wait", 3)
	connect("id_selected", self, "_on_action_selected")

func _on_action_selected(id) -> void:
	match id:
		0: emit_signal("attack_selected")
		1: emit_signal("inventory_selected")
		2: emit_signal("recruit_selected")
		3:emit_signal("wait_selected")
	hide()

func show_menu(cell_pos: Vector2) -> void:
	rect_position = cell_pos
	popup()
