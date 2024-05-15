class_name UnitPath
extends TileMap

export var grid: Resource

var _pathfinder: PathFinder
var curr_path := PoolVector2Array()

#creates Pathfinder instance
func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)

#draw path
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	curr_path = _pathfinder.calc_point_path(cell_start, cell_end)
	for cell in curr_path:
		set_cellv(cell, 0)
	update_bitmask_region()

func stop() -> void:
	_pathfinder = null
	clear()
