extends Object

class_name PathGenerator

var _grid_length: int
var _grid_height: int

var _path: Array[Vector2i]

func _init(length: int, height: int) -> void:
	_grid_length = length
	_grid_height = height
	
func generate_debug_path() -> Array[Vector2i]:
	_path.clear()

	for x in _grid_length - 1:
		_path.append(Vector2i(x, 0))
		_path.append(Vector2i(x, _grid_height - 1))

	for y in _grid_height - 1:
		if not _path.has(Vector2i(0, y)):
			_path.append(Vector2i(0, y))
		if not _path.has(Vector2i(_grid_length - 1, y)):
			_path.append(Vector2i(_grid_length - 1, y))
	
	return _path

func generate_path() -> Array[Vector2i]:
	_path.clear()
	
	var x := 0
	var y := _grid_height / 2
	
	while x < _grid_length:
		if not _path.has(Vector2i(x, y)):
			_path.append(Vector2i(x, y))
			
		var choice : int = randi_range(0, 2)
		
		if choice == 0 or x % 2 == 0 or x == _grid_length - 1:
			x += 1
		elif choice == 1 && y < _grid_height and not _path.has(Vector2i(x, y + 1)):
			y += 1
		elif choice == 2 && y > 0  and not _path.has(Vector2i(x, y - 1)):
			y -= 1
		
	return _path
