extends RigidBody3D

var dmg = 5;
var crit = 2 * dmg;
var speed = 50;
var drop = 0.001;
var grav = ProjectSettings.get_setting("physics/3d/default_gravity") * drop;
var spawn: Vector3;
# TODO: audio

func _ready() -> void:
	$Timer.start();
	spawn = self.global_position;

func _on_timer_timeout() -> void:
	self.queue_free();

func _physics_process(delta: float) -> void:
	linear_velocity.y -= grav * delta;
	do_damage("Player");
	do_damage("Enemy");
	


func do_damage(group):
	var tcrit = max(0, randf_range(-crit, crit));
	for entity in get_tree().get_nodes_in_group(group):
		if entity != get_parent():
			if $Area3D.overlaps_area(entity.head):
				entity.take_damage(dmg*2.5 + tcrit, true, true, spawn);
			if $Area3D.overlaps_body(entity):
				entity.take_damage(dmg+tcrit, true, false, spawn);
	


func do_fire(camera, muzzle, spray, damage=dmg):
	dmg = damage;
	crit = dmg*2;
	var cam_forward = camera.global_transform.basis.z.normalized();
	var rnd_x = randf_range(-1, 1) * spray;
	var rnd_y = randf_range(-1, 1) * spray;
	var spray_dir = Vector3(camera.global_transform.basis.x*rnd_x, camera.global_transform.basis.y * rnd_y, cam_forward)
	self.global_transform.origin = muzzle.global_transform.origin
	self.linear_velocity = -spray_dir.normalized() * speed
	
	
