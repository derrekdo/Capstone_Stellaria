class_name UnitInfo
extends PanelContainer


onready var name_label := $MarginContainer/Information/Details/VBoxContainer/Name
onready var class_label := $MarginContainer/Information/Details/VBoxContainer/Class
onready var level_label := $MarginContainer/Information/Details/VBoxContainer2/HboxContainer/Lvl
onready var turn_label := $MarginContainer/Information/Details/VBoxContainer2/Turn
func _ready() -> void:
	pass # Replace with function body.

func update_info(unit: Unit) -> void:
	name_label.text = unit.unit_name
#	class_label.text = unit.class_type
#	turn_label.text = unit.turn
	print(name_label.text)
	print(unit.turn)
#	print(class_label.text)
#	print(turn_label.text)
	pass

func display(view: bool) -> void:
#	print("here")
	self.visible = view
	
