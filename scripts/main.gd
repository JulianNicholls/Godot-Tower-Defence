extends Node3D

@export var tile_start: PackedScene
@export var tile_end: PackedScene
@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_crossing: PackedScene
@export var tile_enemy: PackedScene
@export var tile_empty: Array[PackedScene]

@export var map_length: int = 24
@export var map_height: int = 14

@export var min_path_size: int = 45
@export var max_path_size: int = 65

@export var min_loops: int = 2
@export var max_loops: int = 4

var _pg: PathGenerator

func _ready() -> void:
	_pg = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	_follow_grid()
	
func _add_curve_point(c3d: Curve3D, v3: Vector3) -> bool:
	c3d.add_point(v3)

	return true

func _follow_grid():
	var box := tile_enemy.instantiate()
	
	var c3d := Curve3D.new()
	
	for element in _pg.path():
		c3d.add_point(Vector3(element.x, 0.4, element.y))

	var p3d := Path3D.new()
	add_child(p3d)
	p3d.curve = c3d
	
	var pf3d := PathFollow3D.new()
	p3d.add_child(pf3d)
	pf3d.add_child(box)
	
	var curr_distance: float = 0.0
	
	while curr_distance < c3d.point_count - 1:
		curr_distance += 0.08
		pf3d.progress = clamp(curr_distance, 0, c3d.point_count - 1.00001)
		await get_tree().create_timer(0.01).timeout

func _complete_grid() -> void:
	for x in range(map_length):
		for y in range(map_height):
			if not _pg.path().has(Vector2i(x, y)):
				var tile: Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0, 3) * 90.0, 0)
		
func _display_path() -> void:
	var path := _pg.generate_path(true)
	
	# Ensure we get a decent path
	while (path.size() < min_path_size or path.size() > max_path_size 
		or _pg.loop_count() < min_loops or _pg.loop_count() > max_loops):
		path = _pg.generate_path(true)

	print("Final Size: ", path.size(), ", Loops: ", _pg.loop_count())
	
	for i in range(_pg.path().size()):
		var score := _pg.tile_score(i)
		var tile: Node3D
		var trotation := Vector3.ZERO

		if score == 2:
			tile = tile_start.instantiate()
			trotation = Vector3(0, 90.0, 0)
		if score == 8:
			tile = tile_start.instantiate()
			trotation = Vector3(0, -90.0, 0)
		elif score == 10:
			tile = tile_straight.instantiate()
			trotation = Vector3(0, 90.0, 0)
		elif score == 1 or score == 4 or score == 5:
			tile = tile_straight.instantiate()
		elif score == 6:
			tile = tile_corner.instantiate()
		elif score == 12:
			tile = tile_corner.instantiate()
			trotation = Vector3(0, -90.0, 0)
		elif score == 3:
			tile = tile_corner.instantiate()
			trotation = Vector3(0, 90.0, 0)
		elif score == 9:
			tile = tile_corner.instantiate()
			trotation = Vector3(0, 180.0, 0)
		elif score == 15:
			tile = tile_crossing.instantiate()
			
		add_child(tile)
		var ptile = _pg.path_tile(i)
		tile.global_position = Vector3(ptile.x, 0, ptile.y)
		tile.global_rotation_degrees = trotation
		
#func _process(delta: float) -> void:
	#pass
