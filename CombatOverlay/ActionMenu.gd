class_name ActionMenu
extends PopupPanel

signal attack_selected
signal inventory_selected
signal recruit_selected
signal wait_selected
signal action_cancelled

onready var attack_button = $VBoxContainer/AttackButton
onready var recruit_button =$VBoxContainer/RecruitButton
onready var wait_button = $VBoxContainer/WaitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_button.connect("pressed", self, "_attack")
	recruit_button.connect("pressed", self, "_recruit")
	wait_button.connect("pressed", self, "_wait")

func _attack() -> void:
	emit_signal("attack_selected")
#	print("attack")
	pass

func _recruit() -> void:
	emit_signal("recruit_selected")
	pass

func _wait() ->void:
	emit_signal("wait_selected")
	pass

func show_menu(cell: Vector2) -> void:
	rect_position = cell
