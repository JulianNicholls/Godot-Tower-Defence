extends Node3D

@export var tile_start: PackedScene
@export var tile_end: PackedScene
@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_crossing: PackedScene
@export var tile_enemy: PackedScene

@export var basic_enemy: PackedScene

@export var tile_empty: Array[PackedScene]

var config: PGConfig = preload("res://resources/basic_path_config.res")

func _ready() -> void:
	_display_path()
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	_follow_grid()
	
func _display_path() -> void:
	var path = pgInstance.path()
	
	print("Final Size: ", path.size(), ", Loops: ", pgInstance.loop_count())
	
	for i in range(pgInstance.path().size()):
		var score := pgInstance.tile_score(i)
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
		var ptile = pgInstance.path_tile(i)
		tile.global_position = Vector3(ptile.x, 0, ptile.y)
		tile.global_rotation_degrees = trotation
		
func _complete_grid() -> void:
	for x in range(config.map_length):
		for y in range(config.map_height):
			if not pgInstance.path().has(Vector2i(x, y)):
				var tile: Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0, 3) * 90.0, 0)
		
func _follow_grid():
	var enemy := basic_enemy.instantiate()
	add_child(enemy)
	
	#var c3d := Curve3D.new()
	#
	#for element in pgInstance.path():
		#c3d.add_point(Vector3(element.x, 0.4, element.y))
#
	#var p3d := Path3D.new()
	#add_child(p3d)
	#p3d.curve = c3d
	#
	#var pf3d := PathFollow3D.new()
	#p3d.add_child(pf3d)
	#pf3d.add_child(enemy)
	#
	#var curr_distance: float = 0.0
	#
	#while curr_distance < c3d.point_count - 1:
		#curr_distance += 0.1
		#pf3d.progress = clamp(curr_distance, 0, c3d.point_count - 1.00001)
		#await get_tree().create_timer(0.01).timeout

func _add_curve_point(c3d: Curve3D, v3: Vector3) -> bool:
	c3d.add_point(v3)

	return true

#func _process(delta: float) -> void:
	#pass
