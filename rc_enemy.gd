extends VehicleBody3D

const MAX_STEER = 0.4
const MAX_RPM = 200
const MAX_TORQUE = 500
const HORSE_POWER = 100
const rev_power = -HORSE_POWER*2
const stuck_time = 0.5

var stuck_timer = 0.0
var is_stuck = false

@onready var f = $rfor
@onready var fr = $rforright
@onready var fl = $rforleft
@onready var r = $rright
@onready var l = $rleft

func calc_engine(accel, rpm):
	return accel * MAX_TORQUE * (1- rpm/MAX_RPM)

func check_and_right():
	if global_transform.basis.y.dot(Vector3.UP) < 0:
		var currot = self.rotation_degrees
		currot.x =0
		currot.z = 0
		self.rotation_degrees = currot

func check_stuck(delta):
	if linear_velocity.length() < 1:
		stuck_timer += delta
	else :
		stuck_timer = 0
	is_stuck = stuck_timer > stuck_time

func update_rays():
	f.force_raycast_update()
	fr.force_raycast_update()
	fl.force_raycast_update()
	r.force_raycast_update()
	l.force_raycast_update()

func is_ray_colliding(ray: RayCast3D) -> bool:
	return ray.is_colliding() and ray.get_collider() is not VehicleBody3D

func _physics_process(delta: float) -> void:
	check_stuck(delta)
	
	var tarsteer = 0.0
	update_rays()
	
	var accel = HORSE_POWER
	if is_ray_colliding(f):
		var dist =  f.get_collision_point().distance_to(global_transform.origin)
		accel *= max(0.1, dist /10.0)
		print("happened")
	if is_ray_colliding(fr) or is_ray_colliding(r):
		tarsteer += MAX_STEER
	if is_ray_colliding(fl) or is_ray_colliding(l):
		tarsteer -= MAX_STEER
		
	
	tarsteer = clamp(tarsteer, -MAX_STEER, MAX_STEER)
	if is_stuck:
		accel = rev_power
		steering = -sign(tarsteer) * MAX_STEER
	else:
		steering = tarsteer
	
	$backLeft.engine_force = calc_engine(accel, abs($backLeft.get_rpm()))
	$backRight.engine_force = calc_engine(accel, abs($backRight.get_rpm()))
	check_and_right()
	
