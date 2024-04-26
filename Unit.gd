tool
class_name Unit
extends Path2D

export var grid: Resource = preload("res://Grid.tres")
#unit movement range
export var move_range := 6

#setget functionality: when the variable value changes, will automaticallly call the function 
#associated that comes after the keyword
#unit texture, sets texture with set_skin
export var skin: Texture setget set_skin
#offsets to align with shadow
export var skin_offset := Vector2.ZERO setget set_skin_offset
#how fast the unit moves
export var move_speed := 600.0

#units coordinates 
var cell := Vector2.ZERO setget set_cell
#toggles the selected animation
var is_selected := false setget set_is_selected
#toggles processing for the unit
var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D

#creates a walk_finished signal to know when unit stops moving
signal walk_finished

func _ready() -> void:
	#move unit along path
	set_process(false)
	
	#initialize the cell property and snap the unit to the cell's center on the map.
	self.cell = grid.calc_grid_coord(position)
	position = grid.calc_map_position(cell)
	
	#create and update curve resource in the inspector 
	if not Engine.editor_hint:
		curve = Curve2D.new()
	var points := [
		Vector2(2,2), Vector2(2,5), Vector2(8,5), Vector2(8,7)
	]
	walk_along(PoolVector2Array(points))

#When active, moves the unit along its curve with the help of the PathFollow2D node.
func _process(delta: float) -> void:
	#PathFollow2D offset property updates and moves the sprites along the curve everyt frame
	_path_follow.offset += move_speed * delta
	
	# When we increase the `offset` above, the `unit_offset` also updates. It represents how far you
	# are along the `curve` in percent, where a value of `1.0` means you reached the end.
	# When that is the case, the unit is done moving.
	
	#checks it movement on path is complete, 1.0 means it completed
	#will move the the unit node itself
	if _path_follow.unit_offset >= 1.0:
		#stops processing for the unit
		self._is_walking = false
		
		#resets the offset to 0, and places the sprite back on the nodes position
		_path_follow.offset = 0.0
		#position the node to center of the targed cell
		position = grid.calc_map_position(cell)
		#clear curve
		curve.clear_points()
		#emit the finshed walking signal
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

#setters for the sprite node
#updates the texture
func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		#wait until node is read
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
	
