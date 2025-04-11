extends VehicleBody3D

const MAX_STEER = 0.4
const MAX_RPM = 700
const MAX_TORQUE = 200
const HORSE_POWER = 100

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func calc_engine(accel, rpm):
	return accel * MAX_TORQUE * (1- rpm/MAX_RPM)

func _physics_process(delta: float) -> void:
	steering = lerp(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 5.0)
	var accel = Input.get_axis("ui_down", "ui_up") * HORSE_POWER
	$backLeft.engine_force = calc_engine(accel, abs($backLeft.get_rpm()))
	$backRight.engine_force = calc_engine(accel, abs($backRight.get_rpm()))
	
	var mps = abs((linear_velocity * transform.basis).z)
	$Speed.text = "%d mph" % (mps * 2.23694)
	
	$centerMass.global_position = $centerMass.global_position.lerp(global_position, delta * 20.0)
	$centerMass.transform = $centerMass.transform.interpolate_with(transform, delta * 5.0)
	$centerMass/Camera3D.look_at(global_position.lerp(global_position + linear_velocity, delta * 5.0))
	
	
	
	check_and_right(delta)
	
	

func check_and_right(delta):
	if global_transform.basis.y.dot(Vector3.UP) < 0:
		
			var currot = self.rotation_degrees
			#currot.x = min(currot.x - delta * 10.0, currot.x + delta * 10.0)
			#currot.z = min(currot.z - delta * 10.0, currot.z + delta * 10.0)
			currot.x = 0
			currot.z = 0
			self.rotation_degrees = currot


func _on_death_plane_body_entered(body: Node3D) -> void:
	get_tree().reload_current_scene()
