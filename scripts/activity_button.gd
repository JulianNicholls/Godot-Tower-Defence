extends Button

const RAYCAST_LENGTH := 100.0

@export var button_icon: Texture2D
@export var button_draggable: PackedScene

var _draggable: Node
var _camera : Camera3D
var _is_dragging := false
var _is_valid_location := false
var _last_valid_location: Vector3

@onready var _error_mat: BaseMaterial3D = preload("res://materials/red_transparent.material")

func _ready():
	icon = button_icon
	
	_draggable = button_draggable.instantiate()
	add_child(_draggable)
	_draggable.visible = false

	_camera = get_viewport().get_camera_3d()
	
## Drag
func _on_button_down() -> void:
	_is_dragging = true


## Drop (if valid)
func _on_button_up() -> void:
	_is_dragging = false
	_draggable.visible = false
	
	if _is_valid_location:
		var activity := button_draggable.instantiate()
		add_child(activity)
		activity.global_position = _last_valid_location


func _physics_process(_delta: float) -> void:
	if _is_dragging:
		var space_state = _draggable.get_world_3d().direct_space_state
		var mouse_pos := get_viewport().get_mouse_position()
		var origin: Vector3 = _camera.project_ray_origin(mouse_pos)
		var end: Vector3 = origin + _camera.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		var ray_result: Dictionary = space_state.intersect_ray(query)
		
		if ray_result.size() > 0:
			var co: CollisionObject3D = ray_result.get("collider")
			var group := co.get_groups()[0]
			
			_draggable.visible = true
			_draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
			
			if group != "tile_empty":
				_is_valid_location = false
				_set_child_mesh_error(_draggable)
			else:
				_is_valid_location = true
				_last_valid_location = _draggable.global_position
				_clear_child_mesh_error(_draggable)
				
		else:
			_draggable.visible = false


func _set_child_mesh_error(n: Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			_set_mesh_override(c, _error_mat)
			
		if c is Node and c.get_child_count() > 0:
			_set_child_mesh_error(c)
			
			
func _clear_child_mesh_error(n: Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			_set_mesh_override(c, null)
			
		if c is Node and c.get_child_count() > 0:
			_clear_child_mesh_error(c)
			
			
func _set_mesh_override(mesh_3d: MeshInstance3D, override: BaseMaterial3D):
	for si in mesh_3d.mesh.get_surface_count():
		mesh_3d.set_surface_override_material(si, override)
		
