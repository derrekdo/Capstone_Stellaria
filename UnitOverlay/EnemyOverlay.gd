class_name EnemyOverlay
extends TileMap

#highlights cells that can be traversed
func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cellv(cell, 0)
