class_name CombatForecast
extends Panel

onready var left_name_label := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/NameLabel
onready var left_level := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Level
onready var left_HP := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/HP
onready var left_damage := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer3/HBoxContainer/VBoxContainer/Damage
onready var left_hit_rate := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/VBoxContainer3/HitRate
onready var left_crit_rate := $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer3/HBoxContainer3/VBoxContainer2/CritRate

onready var right_name_label := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/NameLabel
onready var right_level := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer/Level
onready var right_HP := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer2/HP
onready var right_damage := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer3/HBoxContainer/VBoxContainer/Damage
onready var right_hit_rate := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer3/HBoxContainer2/VBoxContainer3/HitRate
onready var right_crit_rate := $HBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer3/HBoxContainer3/VBoxContainer2/CritRate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _predict_outcome(attacker: Unit, receiver: Unit) -> void:
	left_name_label.text = attacker.unit_name
	left_level.text = str(attacker.level)
	var damage
	if attacker.damage_type == 0:
		damage = attacker.attack - receiver.defense
	else: 
		damage = attacker.magic - receiver.resistance
	
	if attacker.speed >= receiver.speed * 2:
		right_HP.text = str(max(0,receiver.current_hp - damage*2)) + "/" + str(receiver.max_health)
		left_damage.text = str(damage) + " x2"	
	else:
		right_HP.text = str(max(0,receiver.current_hp - damage)) + "/" + str(receiver.max_health) 
		left_damage.text = str(damage)
		
	left_hit_rate.text = str(max(0,attacker.hit_rate - receiver.evade_rate))
	left_crit_rate.text = str(max(0,attacker.crit_rate - receiver.crit_evade))
	
	right_name_label.text = receiver.unit_name
	right_level.text = str(receiver.level)
#	damage = receiver.attack - attacker.defense
#	left_HP.text = str(max(0,attacker.current_hp - damage)) + "/" + str(attacker.max_health)
#	right_damage.text = str(damage)

	if receiver.damage_type == 0:
		damage = receiver.attack - attacker.defense
	else: 
		damage = receiver.magic - attacker.resistance
	left_HP.text = str(max(0,attacker.current_hp - damage)) + "/" + str(attacker.max_health)
	right_damage.text = str(damage)
	right_hit_rate.text = str(receiver.hit_rate - attacker.evade_rate)
	right_crit_rate.text = str(receiver.crit_rate - attacker.crit_evade)

func display(view: bool) -> void:
#	print("here")
	self.visible = view
