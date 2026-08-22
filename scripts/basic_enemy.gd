extends Node3D

var curve_3d: Curve3D

func _ready() -> void:
	curve_3d = Curve3D.new() 	

	for pt in pgInstance.path():
		curve_3d.add_point(Vector3(pt.x, 0, pt.y))
		
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress = 0
	
func _on_spawning_state_entered() -> void:
	print("Spawning")
	
