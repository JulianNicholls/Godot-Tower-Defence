extends Node3D

@export var path_tile: PackedScene

@export var map_length: int = 16
@export var map_height: int = 9

var _pg: PathGenerator

func _ready() -> void:
	_pg = PathGenerator.new(map_length, map_height)
	_display_path()
	
func _display_path() -> void:
	var path: Array[Vector2i] = _pg.generate_path()
	
	for element in path:
		print(element)

		var tile: Node3D = path_tile.instantiate()
		add_child(tile)
		tile.global_position = Vector3(element.x, 0, element.y)

#func _process(delta: float) -> void:
	#pass
