class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const _unit := "res://Units/Unit.tscn"
const _action_menu_scene := preload("res://ActionMenu.tscn")

export var grid: Resource

#unit coords
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

#prepare/wait for child nodes
onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath
onready var _action_menu = _action_menu_scene.instance()


func _ready() -> void:
	_reinitialize()
	add_child(_action_menu)
	_action_menu.hide()
	_action_menu.connect("attack_selected", self, "_on_ActionMenu_attack_selected")
	_action_menu.connect("inventory_selected", self, "_on_ActionMenu_inventory_selected")
	_action_menu.connect("recruit_selected", self, "_on_ActionMenu_recruit_selected")
	_action_menu.connect("wait_selected", self, "_on_ActionMenu_wait_selected")

#spawn player chars, and enemy reinforcements?
func _spawn_units() -> void:
	pass
#deselect unit
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()

func _get_config_warning() -> String:
	if not grid:
		return "missing grid res"
	return ""
	
#check if cell is occupied by unit
func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false

#find what cells the unit can currently move to
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

#updates _unit dictionary based on existing units
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit

#MABYE TODO:change to recursive to optimize
#returns array of cells the unit can walk, using the flood fill algorithm
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	#walkable cells
	var arr := []
	var stack := [cell]
	
	while not stack.empty():
		var curr = stack.pop_back()
		#check if the cell is within bounds
		if not grid.within_bounds(curr):
			continue
		#check if cell has been visited
		if curr in arr:
			continue
		#distance between start and current cell
		var diff: Vector2 = (curr - cell).abs()
		var distance := int(diff.x + diff.y)
		#checks if current cell is within the units walking distance
		if distance > max_distance:
			continue
		#add the cell to the array of walable cells (fill in a cell)
		arr.append(curr)
		#look at neighbors of current cell and add to stack for next iteration
		for direction in DIRECTIONS:
			#the neighbors
			var coords: Vector2 = curr + direction
			#check if cell occupied by another unit
			if is_occupied(coords):
				continue
			if coords in arr:
				continue
			#add to stack
			stack.append(coords)
	return arr

#Updates the _units dictionary with the target position for the unit and moves it
func _move_unit(new_cell: Vector2) -> void:
	#check if empty cell
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.curr_path)
	yield(_active_unit, "walk_finished")
	_clear_active_unit()
	_show_action_menu(new_cell)

#Selectst eh unit
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

#Deselects the active unit (for after movement)
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()

#clear active unit
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

#moves unit after selecting cell
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_unit(closest_cell(cell))

#updates the path
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		var target_cell = closest_cell(new_cell)
		_unit_path.draw(_active_unit.cell, target_cell)

#returns selected cell, or closest cell to unit if selecting another unit
func closest_cell(cell: Vector2) -> Vector2:
	if not _units.has(cell):
		return cell
		
	var close_cell := cell
	var min_dist := 100000
	
	for direction in DIRECTIONS:
		var target: Vector2 = cell + direction
		if _units.has(target) and not _units[target] == _active_unit:
			continue
		
		var dist := target.distance_squared_to(_active_unit.cell)
		if dist < min_dist:
			min_dist = dist
			close_cell = target
			
	return close_cell


func _on_ActionMenu_attack_selected() -> void:
	print("attack")
	pass # Replace with function body.


func _on_ActionMenu_inventory_selected() -> void:
	print("inv")
	pass # Replace with function body.


func _on_ActionMenu_recruit_selected() -> void:
	print("recruit")
	pass # Replace with function body.


func _on_ActionMenu_wait_selected() -> void:
	print("wait")
	pass # Replace with function body.

func _show_action_menu(cell:Vector2) -> void:
	var screen_pos = cell_to_screen_pos(cell)
	_action_menu.show_menu(screen_pos)

func cell_to_screen_pos(cell: Vector2) -> Vector2:
	var cell_size = Vector2(80,80)
	return cell * cell_size
