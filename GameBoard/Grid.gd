class_name Grid
extends Resource

#24x24 grid
export var size := Vector2(24, 24)
#The size of cell
export var cell_size := Vector2(80, 80)

#Half of cell for center
var _half_cell_size = cell_size / 2

#returns position of cells center
#places and moves the character/unit
func calc_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size

#return coord of cell
#used to find coords of a unit(s)
func calc_grid_coords(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()

#return true if cell coords are within grid
#checks to make sure unit is inside the grid
func within_bounds(cell_coords: Vector2) -> bool:
	var out := cell_coords.x >= 0 and cell_coords.x < size.x
	return out and cell_coords.y >= 0 and cell_coords.y < size.y

#Keeps the coord within the bounds of the grid
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	#ensures the coord fits within the girds bounds
	#allows coords to go up to (grid.size-1,grid.size-1) because it starts at 0,0
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out

#calculates and return integer index of the vecotr
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
