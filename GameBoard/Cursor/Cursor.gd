tool
class_name Cursor
extends Node2D

#emits signal when clicking hovered cell
signal accept_pressed(cell)
#emit signal when cursor moves to new cell
signal moved(new_cell)
signal hover(cell)

#grid resource, to allow access to it
export var grid: Resource
#time before cursor can move again
export var ui_cooldown := 0.1

#coordinates of cell being hovered
var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer

#TODO: possibly remove teh timer for cursor movement on echo if i get annoyed
func _ready() -> void:
	#intialize timer
	_timer.wait_time = ui_cooldown
	#places the cursor at center of the cell 
	position = grid.calc_map_position(cell)

#handles interactions with mouse movement/input
func _unhandled_input(event: InputEvent) -> void:
	#If the mouse moves, update the node's cell.
	if event is InputEventMouseMotion:
		self.cell = grid.calc_grid_coords(event.position)
		emit_signal("hover", cell)
	#If hovering over cell and clicking it, interact with it
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		#emit signal of clicking, with the current cell as argument
		emit_signal("accept_pressed", cell)
		#marks the input as handled in the scene trree
		get_tree().set_input_as_handled()

	#boolean to check if if the event is key press
	var should_move := event.is_pressed()
	#if the key press is held down, move after cursor after timer stops
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()
	#prevents cursor from moving if it shouldnt
	if not should_move:
		return

	#update cursor current cell based on input direction
	if event.is_action("ui_right"):
		self.cell += Vector2.RIGHT
	elif event.is_action("ui_up"):
		self.cell += Vector2.UP
	elif event.is_action("ui_left"):
		self.cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		self.cell += Vector2.DOWN

#draws a rectangular outline of the cell the cursor hovers
func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)

#position of the cursor on the grid
func set_cell(value: Vector2) -> void:
	#clamp the cell coord to prevent moving out of bounds
	if not grid.within_bounds(value):
		cell = grid.clamp(value)
	else:
		cell = value
		
	#updates the cursors position and emit signal
	#starts cooldown timer that limits rate which cursor move with a held down key press
	position = grid.calc_map_position(cell)
	emit_signal("moved", cell)
	_timer.start()
