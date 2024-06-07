class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const _unit := "res://Units/Unit.tscn"
const _action_menu_scene := preload("res://ActionMenu.tscn")
const _unit_scene = preload("res://Units/Unit.tscn")
#const _unit_info := preload("res://Units/UnitInfo.tscn")

export var grid: Resource

#unit coords
var _units := {}
var _player_units := {}
var _enemy_units := {}
var _active_unit: Unit
var _walkable_cells := []
var _attackable_cells := []
var _enemy_cells := []
var _occupied := false
var _prev_cell: Vector2


#gameplay variables
var _random = RandomNumberGenerator.new()
enum _turn_phase {PLAYER, ENEMY}
var _current_turn = _turn_phase.PLAYER
#prepare/wait for child nodes
onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _attack_overlay: AttackOverlay = $AttackOverlay
onready var _enemy_overlay: EnemyOverlay = $EnemyOverlay
onready var _unit_path: UnitPath = $UnitPath
#onready var _action_menu := _action_menu_scene.instance()
onready var _unit_info: UnitInfo = $UnitInfo
onready var _target_info: UnitInfo = $TargetInfo
onready var _ally_info: UnitInfo = $AllyInfo
onready var _enemy_info: UnitInfo = $EnemyInfo
onready var _combat_predicton: CombatForecast = $CombatForecast1
onready var _receiver_predicton: CombatForecast = $CombatForecast2
onready var _player_phase_ani: PhaseChange = $PlayerPhase
onready var _enemy_phase_ani: PhaseChange = $EnemyPhase

func _ready() -> void:
	_spawn_units()
	_reinitialize()
	_unit_info.display(false)
	_target_info.display(false)
	_ally_info.display(false)
	_enemy_info.display(false)
	_combat_predicton.display(false)
	
	_random.randomize()
	_player_phase_ani.set_phase_change(false)
	_enemy_phase_ani.set_phase_change(false)
#	_receiver_predicton.display(false)
	_change_phase(true)
#	add_child(_action_menu)
#	_action_menu.hide()
#	_action_menu.connect("attack_selected", self, "_on_action_menu_attack_selected")
#	_action_menu.connect("inventory_selected", self, "_on_action_menu_inventory_selected")
#	_action_menu.connect("recruit_selected", self, "_on_action_menu_recruit_selected")
#	_action_menu.connect("wait_selected", self, "_on_action_menu_wait_selected")
#	_action_menu.connect("action_cancelled", self, "_on_action_menu_action_cancelled")

func _process(delta: float) -> void:
	if _current_turn == _turn_phase.PLAYER and _player_units.empty():
		_change_phase(false)
	elif _current_turn == _turn_phase.ENEMY and _enemy_units.empty():
		_change_phase(true)

#rework action menu before this and also add queue or some data structure to hold all units of a turn taht empties as their turn goes
func _change_phase(player_phase: bool) -> void:
	if player_phase:
		_current_turn = _turn_phase.PLAYER
		_player_phase_ani.set_phase_change(true)
		yield(get_tree().create_timer(3.5), "timeout")
		_player_phase_ani.set_phase_change(false)
	else: 
		_current_turn = _turn_phase.ENEMY
		_enemy_phase_ani.set_phase_change(true)
		yield(get_tree().create_timer(3.5), "timeout")
		_enemy_phase_ani.set_phase_change(false)
	_reinitialize()
		
#spawn player chars, and enemy reinforcements?
func _spawn_units() -> void:
	var starting_cells := [Vector2(6,11), Vector2(2,11),Vector2(4,10), Vector2(2,4), Vector2(4,3)]
	var spawnable_cells := {}
	for unit_data in _process_JSON():
		var unit_instance = _unit_scene.instance()
#		unit_instance.visible(false)
		unit_instance.update_stats(unit_data)
		add_child(unit_instance)
		unit_instance.walk_along([Vector2(0,0), starting_cells[0]])
		starting_cells.remove(0)
#		unit_instance.visible(true)
		
func _process_JSON() -> Array:
	var all_unit_data: Array
	var file_path = "res://Units/playable_units.JSON"
#	var json_as_txt = FileAccess.get_file_as_string(file)
#	var json_as_dict = JSON.parse_string(json_as_txt)
	var file = File.new()
	if file.open(file_path, file.READ) == OK:
		var json_txt = file.get_as_text()
		file.close()
#		print(json_txt)
		var json_dict = JSON.parse(json_txt).result
#		print(json_dict)
		all_unit_data = json_dict.units
	return all_unit_data
	
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
	_player_units.clear()
	_enemy_units.clear()
	
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		if unit.turn == 0:
			_player_units[unit.cell] = unit
		if unit.turn == 1:
			_enemy_units[unit.cell] = unit

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
	if _active_unit.turn == 0:
		_player_units.erase(_active_unit.cell)
#		_player_units[new_cell] = _active_unit
	elif _active_unit.turn == 1:
		_enemy_units.erase(_active_unit.cell)
#		_enemy_units[new_cell] = _active_unit
		
#	if _active_unit.turn == 0:
#		_player_units.erase(_active_unit.cell)
#	else: _enemy_units.erase(_active_unit.cell)
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.curr_path)
	yield(_active_unit, "walk_finished")
	_clear_active_unit()
#	if _occupied:
#	_show_action_menu(new_cell)

#Selectst eh unit
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell) or _units[cell].turn != _current_turn:
		return
	if (_current_turn == _turn_phase.PLAYER and !_player_units.has(cell)) or (_current_turn == _turn_phase.ENEMY and !_enemy_units.has(cell)):
		return
	
	_active_unit = _units[cell]
	print(_active_unit.class_type)
	_active_unit.set_is_selected(true)
	_unit_info.update_info(_active_unit)
	_unit_info.display(true)
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

	if target_unit and target_unit.turn != _active_unit.turn:
#		if _calc_hit(target_unit, _active_unit):
#			var damage := max(0, _active_unit.attack - target_unit.defense)
#			if _calc_crit(target_unit, _active_unit):
#				damage = damage * 2
#			target_unit.current_hp -= damage
#			if target_unit.current_hp <= 0:
#				_units.erase(target_cell)
#				remove_child(target_unit)
		_calc_damage(target_unit, _active_unit)
		
		if target_unit:
			_calc_damage(_active_unit, target_unit)
			if _active_unit and _active_unit.speed >= target_unit.speed * 2:
				print("outspeed")
				_calc_damage(target_unit, _active_unit)
#		if _active_unit.turn == 0:
#			_player_units.erase(_active_unit.cell)
#		else: _enemy_units.erase(_active_unit.cell)
#		_clear_active_unit()
#		if(target_unit.current_hp <= 0):
#
#			_units.erase(target_unit.cell)
#			remove_child(target_unit)
#		_target_info.display(false)
#		_action_menu.hide()

func _calc_damage(receiving_unit: Unit, attacking_unit: Unit) -> void:
	if _calc_hit(receiving_unit, attacking_unit):
		var damage := max(0, attacking_unit.attack - receiving_unit.defense)
		print("we hit for: " + str(damage))
		if _calc_crit(receiving_unit, attacking_unit):
			damage = damage * 2
		receiving_unit.current_hp -= damage
		
		if receiving_unit.current_hp <= 0:
			receiving_unit.play_death()
			yield(get_tree().create_timer(2), "timeout")
			_units.erase(receiving_unit.cell)
			if receiving_unit.turn == 0:
				_player_units.erase(receiving_unit.cell)
			else:
				_enemy_units.erase(receiving_unit.cell)
			remove_child(receiving_unit)
	else: print("miss")

	
func _calc_hit(receiving_unit: Unit, attacking_unit) -> bool:
	var ran_num = _random.randf_range(0.0,100.0)
	print(ran_num)
	if ran_num <= attacking_unit.hit_rate - receiving_unit.evade_rate:
		return true
	return false
	
func _calc_double(receiving_unit: Unit, attacking_unit: Unit) -> void:
	pass

func _calc_crit(receiving_unit: Unit, attacking_unit) -> bool:
	var ran_num = _random.randf_range(0.0, 100.0)
	if ran_num <= attacking_unit.crit_rate - receiving_unit.crit_evade:
		return true
	return false
	
	
func _on_Cursor_hover(cell) -> void:
	if !_active_unit:
		if _units.has(cell):
			if _current_turn == _units[cell].turn:
				_unit_info.update_info(_units[cell])
				_unit_info.display(true)
				_enemy_info.display(false)
			else:
				_enemy_info.update_info(_units[cell])
				_enemy_info.display(true)
			_ally_info.display(false)
			_combat_forecast_display(false)

		else:
			_unit_info.display(false)
			_enemy_info.display(false)
			_combat_forecast_display(false)
	elif _active_unit:
		if _units.has(cell) and cell != _active_unit.cell:
			if _active_unit.turn != _units[cell].turn:
				_ally_info.display(false)
				_target_info.update_info(_units[cell])
				_combat_predicton._predict_outcome(_active_unit, _units[cell])
				_combat_forecast_display(true)
			else:
				_ally_info.update_info(_units[cell])
				_ally_info.display(true)
				_combat_forecast_display(false)
		else:
			_ally_info.display(false)
			_combat_forecast_display(false)

func _combat_forecast_display(visible: bool) -> void:
	_target_info.display(visible)
	_combat_predicton.display(visible)
