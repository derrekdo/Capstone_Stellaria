class_name PathFinder
extends Reference

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var _grid: Resource
#initializes AStar instance (pathfinding algo)
var _astar := AStar2D.new()

#initialize AStar2d object upon creation
func _init(grid: Grid, walkable_cells: Array) -> void:
	_grid = grid
	print(_grid)
	#maps the cell coordinate to their index
	var cell_mappings := {}
	for cell in walkable_cells:
		cell_mappings[cell] = _grid.as_index(cell)
	_add_and_connect_points(cell_mappings)

# Returns the path found as an array of Vector2 coordinates.
func calc_point_path(start: Vector2, end: Vector2) -> PoolVector2Array:
	#need 2 poitns for AStar algo
	var start_index: int = _grid.as_index(start)
	var end_index: int = _grid.as_index(end)	
	
	#checks that the 2 points exist
	if _astar.has_point(start_index) and _astar.has_point(end_index):
		#AStar algo will find best and possible shortest path
		return _astar.get_point_path(start_index, end_index)
	else:
		#emtpy array
		return PoolVector2Array()


#add cells to AStar2d and connects them
func _add_and_connect_points(cell_mappings: Dictionary) -> void:
	#adds the cells to the AStar2d 
	for point in cell_mappings:
		_astar.add_point(cell_mappings[point], point)
	#connects cells to their neighbors
	for point in cell_mappings:
		#find all neighbors of the cell
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			#connects cell to its neighbors
			_astar.connect_points(cell_mappings[point], neighbor_index)

#returns array of the current cells neighbors
func _find_neighbor_indices(cell: Vector2, cell_mappings: Dictionary) -> Array:
	var neighbors := []
	#will check all 4 directions for possible neighbors 
	for direction in DIRECTIONS:
		var neighbor: Vector2 = cell + direction
		#double checks that the cell is walkable (and not wall/outof bounds)
		if not cell_mappings.has(neighbor):
			continue
		#checks if the cell is connected to the current neighbor
		if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			#adds the neighbor to the arra
			neighbors.push_back(cell_mappings[neighbor])
	return neighbors
