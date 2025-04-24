extends VehicleBody3D

const MAX_STEER = 0.4
const MAX_RPM = 800
const MAX_TORQUE = 100
const HORSE_POWER = 150

var laps = 1
var checkpoints = [false, false, false, false]

var idle = preload("res://Assets/Sounds/loop_0.wav") 
var moving = preload("res://Assets/Sounds/car-interior-2.mp3")

func reset_checkpoints():
	checkpoints = [false, false, false, false]

func do_lap():
	laps += 1
	reset_checkpoints() 
	if laps > 3:
		await get_tree().create_timer(0.25).timeout
		OS.alert("You Win!")
	else :
		$Laps.text = "Lap %d/3" % laps
	pass

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
	
	if accel > 0:
		var max_dB = 110
		var dB = clamp(max_dB * abs($backLeft.engine_force/MAX_RPM), -10, max_dB)
		$AudioStreamPlayer3D.volume_db = dB
		if $AudioStreamPlayer3D.stream == idle:
			$AudioStreamPlayer3D.stream = moving
			$AudioStreamPlayer3D.play()  # change the stream to the vroom sound and play
		elif not $AudioStreamPlayer3D.is_playing():
			$AudioStreamPlayer3D.play()
	else:
		$AudioStreamPlayer3D.volume_db = 10  # default
		$AudioStreamPlayer3D.stream = idle
		$AudioStreamPlayer3D.play()
	# change the stream to the idle sound and play
	
	check_and_right(delta)
	
	

func check_and_right(delta):
	if global_transform.basis.y.dot(Vector3.UP) < 0:
		
			var currot = self.rotation_degrees
			#currot.x = min(currot.x - delta * 10.0, currot.x + delta * 10.0)
			#currot.z = min(currot.z - delta * 10.0, currot.z + delta * 10.0)
			currot.x = - currot.x / 2
			currot.z = -currot.z / 2
			self.rotation = Vector3(0, 0, 0)
			self.rotation_degrees = currot


func _on_death_plane_body_entered(body: Node3D) -> void:
	if body == self:
		get_tree().reload_current_scene()
