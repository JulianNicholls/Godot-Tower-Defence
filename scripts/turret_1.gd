extends Node3D

var _enemies_in_range: Array[Node3D]

func set_patrolling(on: bool) -> void:
	%PatrolZone.monitoring = on
	

func _on_patrol_zone_area_entered(area: Area3D) -> void:
	_enemies_in_range.append(area.get_node("../../.."))
	print(area, " Entered, in range: ", _enemies_in_range.size())
	

func _on_patrol_zone_area_exited(area: Area3D) -> void:
	_enemies_in_range.erase(area.get_node("../../.."))
	print(area, " Exited, in range: ", _enemies_in_range.size())
