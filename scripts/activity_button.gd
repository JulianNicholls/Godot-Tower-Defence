extends Button

@export var button_icon: Texture2D
@export var button_draggable: PackedScene

var _is_dragging := false
var _draggable: Node
var _camera : Camera3D

var RAYCAST_LENGTH := 100.0

func _ready():
	icon = button_icon
	
	_draggable = button_draggable.instantiate()
	add_child(_draggable)
	_draggable.visible = false

	_camera = get_viewport().get_camera_3d()
	
	
func _on_button_down() -> void:
	_is_dragging = true
	print("Drag Start")


func _on_button_up() -> void:
	_is_dragging = false
	print("Drag End")


func _physics_process(delta: float) -> void:
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
			print(co.get_groups()[0])
