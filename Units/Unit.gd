tool
class_name Unit
extends Path2D

#creates a walk_finished signal to know when unit stops moving
signal walk_finished
signal unit_death
export var grid: Resource
#unit texture
export var skin: Texture setget set_skin
#readjust position of the sprite
export var skin_offset := Vector2.ZERO setget set_skin_offset
#export var hframe: int = 0 setget set_hframe
#export var vframe: int = 0 setget set_vframe
#how fast the unit moves
export var move_speed := 600.0
export var unit_name := "Proxy"
export var level := 1
export var experience := 0
var _level_up := 50
var _exp_value := 5
#export var job_class := "Knight"
#unit movement range
export var move_range := 6
export var attack_range := 1
#units health points
export var max_health := 20
var current_hp := max_health
#units attack stat
export var attack := 4
export var speed := 4
#units magic attack stat
export var magic := 2
#units defense stat (for attack)
export var defense := 3
#units resistance stat (for magic)
export var resistance := 6
export var hit_rate := 50
export var crit_rate := 10
export var evade_rate := 15
export var crit_evade := 5
enum classes {
	Mercenary, Archer, Sniper, Blademaster, Mage, Sage, Priest, Warlock, Assassin, Rogue,
	Cavelier, Pegasus_Knight, Villager, Thief
}
enum attack_type {Physical, Special}
var attack_type_dict = {
	0: "Physical",
	1: "Special"
}
var class_dict = {
	0: "Mercenary",
	1: "Archer",
	2: "Sniper",
	3: "Blademaster",
	4: "Mage",
	5: "Sage",
	6: "Priest",
	7: "Warlock",
	8: "Assassin",
	9: "Rogue",
	10: "Cavelier",
	11: "Pegasus Knight",
	12: "Villager",
	13: "Thief"
}

var unit_type = {
	0: "Player",
	1: "Enemy",
	2: "Neutral"
}

enum unit_turn {Player, Enemy, Neutral}
export(attack_type) var damage_type
export(unit_turn) var turn
export(classes) var class_type

#coord of current cell
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected
var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_process(false)
	current_hp = max_health
	#initialize the cell property and snap the unit to the cell's center on the map.
	self.cell = grid.calc_grid_coords(position)
	position = grid.calc_map_position(cell)
	#create and update curve resource in the inspector 
	if not Engine.editor_hint:
		curve = Curve2D.new()

#When active, moves the unit along its curve with the help of the PathFollow2D node.
func _process(delta: float) -> void:
	#PathFollow2D offset property updates and moves the sprites along the curve everyt frame
	_path_follow.offset += move_speed * delta
	
	#checks it movement on path is complete, 1.0 means it completed
	#will move the the unit node itself
	if _path_follow.offset >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.offset = 0
		position = grid.calc_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")

#Starts movement on the path
#path is an array of grid coords
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calc_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true

func play_death() -> void:
	_anim_player.play("Death")
	emit_signal("unit_death")

	
func curr_class(key: int) -> String:
	return class_dict[key]




func get_unit_type(key: int) -> String:
	return unit_type[key]

func change_damage_type(value: String) -> void:
	for key in attack_type_dict.keys():
		if attack_type_dict[key] == value:
			print(unit_name + " " + str(key))
			damage_type = key
			return

func change_class(value: String) -> void:
	for key in class_dict.keys():
		if class_dict[key] == value:
			class_type = key
			return

func change_team() -> void:
	turn = unit_turn.Player

#prevents coord from being out of bounds when changing the cell
func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

#toggles the selected animation
func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value

func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value

func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func update_stats(unit: Dictionary) -> void:
	unit_name = unit["Name"]
	change_class(unit["Class"])
	max_health = unit["Health"]
	current_hp = max_health
	attack = unit["Attack"]
	magic = unit["Magic"]
	crit_rate = unit["CritRate"]
	hit_rate = unit["HitRate"]
	defense = unit["Defense"]
	resistance = unit["Resistance"]
	speed = unit["Speed"]
	evade_rate = unit["Evasion"]
	crit_evade = unit["CritEvade"]
	move_range = unit["Movement"]
	set_skin(load(unit["Skin"]))
	change_damage_type(unit["AttackType"])
	
	
