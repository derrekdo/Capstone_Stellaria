class_name UnitPath
extends TileMap

export var grid: Resource

#pathfinder reference
var _pathfinder: PathFinder
#current path
var curr_path := PoolVector2Array()

#func _ready() -> void:
#	pass
#	#test
#	var rect_start := Vector2(4,4)
#	var rect_end := Vector2(10,8)
#	var point := []
#	for x in rect_end.x - rect_start.x + 1:
#		for y in rect_end.y - rect_start.y + 1:
#			point.append(rect_start + Vector2(x,y))
#	initialize(point)
#	draw(rect_start, Vector2(8,7))


#creates Pathfinder instance
func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)

#draw path
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	curr_path = _pathfinder.calc_point_path(cell_start, cell_end)
	for cell in curr_path:
		set_cellv(cell,0)
	update_bitmask_region()

func stop() -> void:
	_pathfinder = null
	clear()
