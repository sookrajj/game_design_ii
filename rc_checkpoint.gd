extends Area3D

@export var cp_index : int = 0



func _on_body_entered(body: Node3D) -> void:
	if (body is VehicleBody3D and body.is_in_group("player")):
		body.checkpoints[cp_index] = true
		if cp_index == len(body.checkpoints)-1 and body.checkpoints[len(body.checkpoints)-2] :
			body.do_lap()
