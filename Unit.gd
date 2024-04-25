tool
class_name Unit
extends Path2D

export var grid: Resource = preload("res://Grid.tres")
#unit movement range
export var move_range := 6
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
#toggles processing
var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D

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
	
#left off at smooth move logic
