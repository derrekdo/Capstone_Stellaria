class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const _unit := "res://Units/Unit.tscn"
const _action_menu_scene := preload("res://ActionMenu.tscn")
#const _unit_info := preload("res://Units/UnitInfo.tscn")

export var grid: Resource

#unit coords
var _units := {}
var _active_unit: Unit
var _walkable_cells := []
var _attackable_cells := []
var _enemy_cells := []
var _occupied := false

#prepare/wait for child nodes
onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _attack_overlay: AttackOverlay = $AttackOverlay
onready var _enemy_overlay: EnemyOverlay = $EnemyOverlay
onready var _unit_path: UnitPath = $UnitPath
#onready var _action_menu := _action_menu_scene.instance()
onready var _unit_info: UnitInfo = $UnitInfo

func _ready() -> void:
	_reinitialize()
#	add_child(_action_menu)
#	_action_menu.hide()
#	_action_menu.connect("attack_selected", self, "_on_action_menu_attack_selected")
#	_action_menu.connect("inventory_selected", self, "_on_action_menu_inventory_selected")
#	_action_menu.connect("recruit_selected", self, "_on_action_menu_recruit_selected")
#	_action_menu.connect("wait_selected", self, "_on_action_menu_wait_selected")
#	_action_menu.connect("action_cancelled", self, "_on_action_menu_action_cancelled")

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
	return _units.has(cell)

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
		if distance == max_distance +1:
			_attackable_cells.append(curr)
			continue
		elif distance > max_distance:
			continue
		#add the cell to the array of walable cells (fill in a cell)
		arr.append(curr)
		#look at neighbors of current cell and add to stack for next iteration
		for direction in DIRECTIONS:
			#the neighbors
			var coords: Vector2 = curr + direction
			#check if cell occupied by another unit
			if is_occupied(coords) and coords != _active_unit.cell:
				if !(coords in _enemy_cells):
					_enemy_cells.append(coords)
					print(_enemy_cells)
				continue
			if coords in arr:
				continue
			#add to stack
			stack.append(coords)
	return arr

#Updates the _units dictionary with the target position for the unit and moves it
func _move_unit(new_cell: Vector2) -> void:
	if new_cell == _active_unit.cell:
		pass
	#check if empty cell
	elif is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.curr_path)
	yield(_active_unit, "walk_finished")
#	_clear_active_unit()
#	if _occupied:
#	_show_action_menu(new_cell)

#Selectst eh unit
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_enemy_overlay.draw(_enemy_cells)
	_attack_overlay.draw(_attackable_cells)
	_unit_path.initialize(_walkable_cells)

#Deselects the active unit (for after movement)
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_enemy_overlay.clear()
	_attack_overlay.clear()
	_unit_path.stop()

#clear active unit
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()
	_enemy_cells.clear()
	_attackable_cells.clear()

#moves unit after selecting cell
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	#check if unit is selected
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		if _occupied:
			print("runs yep")
			_move_unit(closest_cell(cell))
			_handle_attack(cell)
			_occupied = false
			#MAKE ATTACK HERE
		else:
			_move_unit(cell)

#updates the path both internally and visually
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		var target_cell = closest_cell(new_cell)
#		print("ALL enemy cells ",_enemy_cells)
#		print("mouse cell ", new_cell)
		#will draw a path near an enemy if they are hovered
		if _enemy_cells.has(new_cell):
			_unit_path.draw(_active_unit.cell, target_cell)
			_occupied = is_occupied(new_cell)
		else:	
		#draw a path to current cell hovered
			_unit_path.draw(_active_unit.cell, new_cell)

#returns selected cell, or closest cell to unit if selecting another unit
func closest_cell(cell: Vector2) -> Vector2:
	if not _units.has(cell):
		return cell
		
	var close_cell := cell
	var min_dist := INF
	
	for direction in DIRECTIONS:
		var target: Vector2 = cell + direction
		if _units.has(target) and not _units[target] == _active_unit:
			continue
		
		var dist := target.distance_squared_to(_active_unit.cell)
		if dist < min_dist:
			min_dist = dist
			close_cell = target
			
	return close_cell


func _on_action_menu_attack_selected() -> void:
	print("attack")
	_display_range()
	
	#Allow clicking the nearby unit to attack
#	set_process_input(true)


func _display_range() -> void:
	_attackable_cells = get_attackable_cells(_active_unit)
	_enemy_overlay.draw(_attackable_cells)
	

func _on_action_menu_inventory_selected() -> void:
	print("inv")
	pass # Replace with function body.


func _on_action_menu_recruit_selected() -> void:
	print("recruit")
	pass # Replace with function body.


func _on_action_menu_wait_selected() -> void:
	print("wait")
	_clear_active_unit()
	pass # Replace with function body.

func _show_action_menu(cell:Vector2) -> void:
	var screen_pos = cell_to_screen_pos(cell)
#	_action_menu.show_menu(screen_pos)
	
func cell_to_screen_pos(cell: Vector2) -> Vector2:
	var cell_size = Vector2(110,75)
	return cell * cell_size


func _on_action_menu_action_cancelled() -> void:
	pass # Replace with function body.

func get_attackable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, 1)

func _handle_attack(target_cell: Vector2) -> void:
	
	if not is_occupied(target_cell):
		return
	var target_unit: Unit = _units[target_cell]
	print("Unit Name ", _active_unit.unit_name)
	print("Unit Health ", _active_unit.health)
	print("Unit Attack ", _active_unit.attack)
	print("Target Name ", target_unit.unit_name)
	print("Target Health ", target_unit.health)
	print("Target Defense ", target_unit.defense)
	print("Target Atta,", target_unit.attack)
	if target_unit and target_unit.turn != _active_unit.turn:
		var damage := max(0, _active_unit.attack - target_unit.defense)
		target_unit.health -= damage
		if target_unit.health <= 0:
			_units.erase(target_cell)
			remove_child(target_unit)
#			queue_free(target_unit)
		print("AFTER -----")
		print("Target Name ", target_unit.name)
		print("Target Health", target_unit.health)
		_clear_active_unit()
#		_action_menu.hide()
