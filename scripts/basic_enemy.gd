extends Node3D

var curve_3d: Curve3D
var enemy_progress: float = 0
@export var enemy_speed: float = 4.0

func _ready() -> void:
	curve_3d = Curve3D.new() 	

	for pt in pgInstance.path():
		curve_3d.add_point(Vector3(pt.x, 0, pt.y))
		
	$Path3D.curve = curve_3d
	$Path3D/PathFollow3D.progress = 0
	
func _on_spawning_state_entered() -> void:
	#print("Spawning")
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	
	$EnemyStateChart.send_event("to_travelling")

func _on_travelling_state_processing(delta: float) -> void:
	enemy_progress += delta * enemy_speed
	$Path3D/PathFollow3D.progress = enemy_progress
	
	if enemy_progress > pgInstance.path().size():
		#print("complete")
		$EnemyStateChart.send_event("to_despawning")

func _on_despawning_state_entered() -> void:
	print("despawning")
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	
	queue_free()	
