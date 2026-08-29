extends Node3D

@export var tile_start: PackedScene
@export var tile_end: PackedScene
@export var tile_straight: PackedScene
@export var tile_corner: PackedScene
@export var tile_crossing: PackedScene
@export var tile_enemy: PackedScene
@export var tile_empty: Array[PackedScene]

@export var basic_enemy: PackedScene

@onready var cam := $MainCamera

var RAYCAST_LENGTH := 100.0

var config: PGConfig = preload("res://resources/basic_path_config.res")

func _ready() -> void:
	_display_path()
	_complete_grid()
	
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
	for i in 20:
		await get_tree().create_timer(1.2).timeout

		var enemy := basic_enemy.instantiate()
		add_child(enemy)

# When the board is clicked on, return what sort of tile is clicked via raycasting
func _physics_process(_delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var space_state := get_world_3d().direct_space_state
		var mouse_pos := get_viewport().get_mouse_position()
		var origin: Vector3 = cam.project_ray_origin(mouse_pos)
		var end: Vector3 = origin + cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var ray_result := space_state.intersect_ray(query)
		
		if ray_result.size() > 0:
			#print(ray_result)
			var co: CollisionObject3D = ray_result.get("collider")
			print(co.get_groups())
		
#func _process(delta: float) -> void:
	#pass
