class_name UnitInfo
extends Panel


onready var name_label := $PanelContainer/MarginContainer/Information/Details/VBoxContainer/Name
onready var class_label := $PanelContainer/MarginContainer/Information/Details/VBoxContainer/Class
onready var level := $PanelContainer/MarginContainer/Information/Details/VBoxContainer/HBoxContainer/Level
onready var turn_label := $PanelContainer/MarginContainer/Information/Details/VBoxContainer/Turn
onready var health := $PanelContainer/MarginContainer/Information/Health/HP
onready var attack := $PanelContainer/MarginContainer/Information/Stats/Offensive/HBoxContainer/AttackPoints
onready var magic := $PanelContainer/MarginContainer/Information/Stats/Offensive/HBoxContainer2/MagicPoints
onready var hit_rate := $PanelContainer/MarginContainer/Information/Stats/Offensive/HBoxContainer3/HitRate
onready var crit_rate := $PanelContainer/MarginContainer/Information/Stats/Offensive/HBoxContainer4/CriticalChance
onready var defense := $PanelContainer/MarginContainer/Information/Stats/Protection/HBoxContainer/DefensePoints
onready var resist := $PanelContainer/MarginContainer/Information/Stats/Protection/HBoxContainer2/ResistancePoints
onready var evade := $PanelContainer/MarginContainer/Information/Stats/Protection/HBoxContainer3/EvasionRate
onready var crit_evade := $PanelContainer/MarginContainer/Information/Stats/Protection/HBoxContainer4/CriticalEvasion
onready var speed := $PanelContainer/MarginContainer/Information/Stats/Misc/HBoxContainer3/Speed
onready var move := $PanelContainer/MarginContainer/Information/Stats/Misc/HBoxContainer/MoveRange
onready var attack_range := $PanelContainer/MarginContainer/Information/Stats/Misc/HBoxContainer2/AttackRange

var _phase := {
	0: "Player",
	1: "Enemy"
}


func update_info(unit: Unit) -> void:
	name_label.text = unit.unit_name
	class_label.text = unit.curr_class(unit.class_type)
	level.text = str(unit.level)
	turn_label.text = unit.get_unit_type(unit.turn)
	health.text = str(unit.current_hp) + "/" + str(unit.max_health)
	attack.text = str(unit.attack)
	magic.text = str(unit.magic)
	hit_rate.text = str(unit.hit_rate)
	crit_rate.text = str(unit.crit_rate)
	defense.text = str(unit.defense)
	resist.text = str(unit.resistance)
	evade.text = str(unit.evade_rate)
	crit_evade.text = str(unit.crit_evade)
	speed.text = str(unit.speed)
	move.text = str(unit.move_range)
	attack_range.text = str(unit.attack_range)

func display(view: bool) -> void:
	self.visible = view
	
