extends Object

class_name PathGenerator

var _grid_length: int
var _grid_height: int

var _path: Array[Vector2i]

func _init(length: int, height: int) -> void:
	_grid_length = length
	_grid_height = height
	
func generate_path() -> Array[Vector2i]:
	_path.clear()
	
	var x := 0
	var y := int(_grid_height / 2.0)
	
	while x < _grid_length:
		if not _path.has(Vector2i(x, y)):
			_path.append(Vector2i(x, y))
			
		var choice : int = randi_range(0, 2)
		
		if choice == 0 or x % 2 == 0 or x == _grid_length - 1:
			x += 1
		elif choice == 1 && y < _grid_height - 2 and not _path.has(Vector2i(x, y + 1)):
			y += 1
		elif choice == 2 && y > 1  and not _path.has(Vector2i(x, y - 1)):
			y -= 1
		
	return _path
	
func tile_score(tile: Vector2i) -> int: 
	var x := tile.x
	var y := tile.y
	var score := 0
	
	score += 1 if _path.has(Vector2i(x, y - 1)) else 0
	score += 2 if _path.has(Vector2i(x + 1, y)) else 0
	score += 4 if _path.has(Vector2i(x, y + 1)) else 0
	score += 8 if _path.has(Vector2i(x - 1, y)) else 0
		
	return score
	
func path() -> Array[Vector2i]:
	return _path


func _generate_debug_path() -> Array[Vector2i]:
	_path.clear()

	for x in range(_grid_length):
		_path.append(Vector2i(x, 0))
		_path.append(Vector2i(x, _grid_height - 1))

	for y in range(_grid_height):
		if not _path.has(Vector2i(0, y)):
			_path.append(Vector2i(0, y))
		if not _path.has(Vector2i(_grid_length - 1, y)):
			_path.append(Vector2i(_grid_length - 1, y))
	
	return _path
