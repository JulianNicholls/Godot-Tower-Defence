extends Node3D

@export var tile_start: PackedScene
@export var tile_end: PackedScene
@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_empty: PackedScene

@export var map_length: int = 16
@export var map_height: int = 9

var _pg: PathGenerator

func _ready() -> void:
	_pg = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()
	
func _display_path() -> void:
	var path: Array[Vector2i] = _pg.generate_path()
	
	# Ensure we get a decent path
	while path.size() < 35:
		path = _pg.generate_path()
	
	for element in path:
		var score := _pg.tile_score(element)
		var tile: Node3D = tile_empty.instantiate()
		var rotation = Vector3.ZERO

		if score == 2:
			tile = tile_start.instantiate()
			rotation = Vector3(0, 90.0, 0)
		if score == 8:
			tile = tile_start.instantiate()
			rotation = Vector3(0, -90.0, 0)
		elif score == 10:
			tile = tile_straight.instantiate()
			rotation = Vector3(0, 90.0, 0)
		elif score == 1 or score == 4 or score == 5:
			tile = tile_straight.instantiate()
		elif score == 6:
			tile = tile_corner.instantiate()
		elif score == 12:
			tile = tile_corner.instantiate()
			rotation = Vector3(0, -90.0, 0)
		elif score == 3:
			tile = tile_corner.instantiate()
			rotation = Vector3(0, 90.0, 0)
		elif score == 9:
			tile = tile_corner.instantiate()
			rotation = Vector3(0, 180.0, 0)
			

		add_child(tile)
		tile.global_position = Vector3(element.x, 0, element.y)
		tile.global_rotation_degrees = rotation
		
func _complete_grid() -> void:
	for x in range(map_length):
		for y in range(map_height):
			if not _pg.path().has(Vector2i(x, y)):
				var tile: Node3D = tile_empty.instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
		
#func _process(delta: float) -> void:
	#pass
