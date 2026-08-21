extends Node

var config: PGConfig = preload("res://resources/basic_path_config.res")

var _grid_height: int
var _grid_length: int

var _loop_count: int

var _path: Array[Vector2i]

func _init() -> void:
	_grid_height = config.map_height
	_grid_length = config.map_length

	# Ensure we get a decent path
	while (_path.size() < config.min_path_size or _path.size() > config.max_path_size 
		or _loop_count < config.min_loops or _loop_count > config.max_loops):
		generate_path()	
		
func generate_path() -> void:
	randomize()
	_path.clear()
	_loop_count = 0
		
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
		
	if config.add_loops:
		_add_loops()

func tile_score(index: int) -> int: 
	var x := _path[index].x
	var y := _path[index].y
	var score := 0
	
	score += 1 if _path.has(Vector2i(x, y - 1)) else 0
	score += 2 if _path.has(Vector2i(x + 1, y)) else 0
	score += 4 if _path.has(Vector2i(x, y + 1)) else 0
	score += 8 if _path.has(Vector2i(x - 1, y)) else 0
		
	return score

func loop_count() -> int:
	return _loop_count
		
func path() -> Array[Vector2i]:
	return _path

func _add_loops() -> void:
	# See if we can add any loops
	var loops_generated := true
	
	# Keep generating loops until you can't any more!
	while loops_generated:
		loops_generated = false

		for i in range(_path.size()):
			var loop := _is_loop_option(i)
			# If the loops size > 0, then _is_loop_option found a loop... So add
			# it to the array!
			if loop.size() > 0:
				loops_generated = true

				for j in range(loop.size()):
					_path.insert(i + 1 + j, loop[j])

## For a given index in the path, evaluate whether a loop can be generated
## around it.
func _is_loop_option(index: int) -> Array[Vector2i]:
	var x := _path[index].x
	var y := _path[index].y
	var return_path: Array[Vector2i]

	#Yellow
	if (x < _grid_length-1 and y > 1
		and _tile_loc_free(x, y-3) and _tile_loc_free(x+1, y-3) and _tile_loc_free(x+2, y-3)
		and _tile_loc_free(x-1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x+1, y-2)
		and _tile_loc_free(x+2, y-2) and _tile_loc_free(x+3, y-2)
		and _tile_loc_free(x-1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x+1, y-1) 
		and _tile_loc_free(x+2, y-1) and _tile_loc_free(x+3, y-1)
		and _tile_loc_free(x+1,y) and _tile_loc_free(x+2,y) and _tile_loc_free(x+3,y)
		and _tile_loc_free(x+1,y+1) and _tile_loc_free(x+2,y+1)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y-1), Vector2i(x+2,y-2), Vector2i(x+1,y-2), Vector2i(x,y-2), Vector2i(x,y-1)]

		if _path[index-1].y > y:
			return_path.reverse()

		_loop_count += 1
		return_path.append(Vector2i(x,y))
	#Blue
	elif (x > 2 and y > 1
		and _tile_loc_free(x, y-3) and _tile_loc_free(x-1, y-3) and _tile_loc_free(x-2, y-3)
		and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
		and _tile_loc_free(x+1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x-2, y-1)
		and _tile_loc_free(x-3, y-1)
		and _tile_loc_free(x+1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x-1, y-2)
		and _tile_loc_free(x-2, y-2) and _tile_loc_free(x-3, y-2)
		and _tile_loc_free(x-1, y+1) and _tile_loc_free(x-2, y+1)):
		return_path = [Vector2i(x,y-1), Vector2i(x,y-2), Vector2i(x-1,y-2), Vector2i(x-2,y-2), Vector2i(x-2,y-1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if _path[index-1].x > x:
			return_path.reverse()

		_loop_count += 1
		return_path.append(Vector2i(x,y))
	#Red
	elif (x < _grid_length-1 and y < _grid_height-2
		and _tile_loc_free(x, y+3) and _tile_loc_free(x+1, y+3) and _tile_loc_free(x+2, y+3)
		and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1)
		and _tile_loc_free(x+1, y) and _tile_loc_free(x+2, y) and _tile_loc_free(x+3, y)
		and _tile_loc_free(x-1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x+2, y+1)
		and _tile_loc_free(x+3, y+1)
		and _tile_loc_free(x-1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x+1, y+2)
		and _tile_loc_free(x+2, y+2) and _tile_loc_free(x+3, y+2)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y+1), Vector2i(x+2,y+2), Vector2i(x+1,y+2), Vector2i(x,y+2), Vector2i(x,y+1)]

		if _path[index-1].y < y:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x,y))
	# Brown
	elif (x > 2 and y < _grid_height-2
		and _tile_loc_free(x, y+3) and _tile_loc_free(x-1, y+3) and _tile_loc_free(x-2, y+3)
		and _tile_loc_free(x-1, y-1) and _tile_loc_free(x-2, y-1)
		and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
		and _tile_loc_free(x+1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x-2, y+1) 
		and _tile_loc_free(x-3, y+1)
		and _tile_loc_free(x+1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x-1, y+2)
		and _tile_loc_free(x-2, y+2) and _tile_loc_free(x-3, y+2)):
		return_path = [Vector2i(x,y+1), Vector2i(x,y+2), Vector2i(x-1,y+2), Vector2i(x-2,y+2), Vector2i(x-2,y+1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if _path[index-1].x > x:
			return_path.reverse()
		
		_loop_count += 1
		return_path.append(Vector2i(x,y))
		
	return return_path
	
## Returns true if there is a path tile at the x,y coordinate.
func _tile_loc_taken(x: int, y: int) -> bool:
	return _path.has(Vector2i(x,y))
	
## Returns true if there is no path tile at the x,y coordinate.
func _tile_loc_free(x: int, y: int) -> bool:
	return not _tile_loc_taken(x,y)

## Returns the Vector2i path tile at the given index.
func path_tile(index: int) -> Vector2i:
	return _path[index]



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
