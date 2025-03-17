extends CharacterBody3D


var SPEED = 7.0
var NORMAL_SPEED = SPEED
var WALK_SPEED = 4.0
var JUMP_VELOCITY = 7.0

var MAX_HEALTH = 100
var HEALTH = MAX_HEALTH
var damage_lock = 0.0  # Prevent infinite damage
var inertia = Vector3()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.5
var dart = preload("res://fps_dart.tscn");
var blaster
var muzzle
var old_blaster_y
var spray_lock = 0.0; # prevent infinite spray
var normspray = 0.03;
var crouchspray = 0.01;
var spray = normspray;
var fire_delay = 0.075;
var attack = 5.0;
var knockback = 10.0;


var ammo = 30;
var clip_size = 30;
var tot_ammo = 150;
var is_reloading = false;

var norm_ht = 2.0;
var crouch_ht = 1.25;
var norm_col_rad = .5;
var crouch_col_rad = .8;
var norm_head = 0.8;
var crouch_head = 0.4;

@onready var camera = $Head/Camera3D
var CAM_SENSITIVITY = 0.02
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0


var damage_shader = preload("res://assets/shaders/take_damage.tres")
@onready var head = $Head


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("fire"):
		do_fire()
	spray_lock = max(spray_lock-delta, 0);
	
	#TODO: blaster position
	if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("fire") and ammo == 0):
		if tot_ammo > 0 and not is_reloading and ammo != clip_size:
			is_reloading = true
			# TODO: play sound
			await get_tree().create_timer(2).timeout
			var ammo_need = clip_size - ammo
			var new_ammo = min(ammo_need, tot_ammo)
			ammo += new_ammo
			tot_ammo -= new_ammo
		
			is_reloading = false
	
	#TODO HUD
	#TODO aiming sight
	
	if Input.is_action_just_pressed("crouch"):
		$CollisionShape3D.shape.height = crouch_ht + 0.05
		$CollisionShape3D.shape.radius = crouch_col_rad
		$MeshInstance3D.scale.y = crouch_ht/ norm_ht
		head.position.y = lerp(head.position.y, crouch_head, delta * 5.0)
		spray = crouchspray
	
	if Input.is_action_just_released("crouch"):
		$CollisionShape3D.shape.height = norm_ht + 0.05
		$CollisionShape3D.shape.radius = norm_col_rad
		$MeshInstance3D.scale.y = 1
		head.position.y = lerp(head.position.y, norm_head, delta * 5.0)
		spray = normspray
	
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("walk") or Input.is_action_just_pressed("crouch"):
		SPEED = WALK_SPEED
	else :
		SPEED = NORMAL_SPEED
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	var hbob = headbob(t_bob)
	camera.transform.origin = hbob 
	
	damage_lock = max(damage_lock-delta, 0.0)
	velocity += inertia
	inertia = inertia.move_toward(Vector3(), delta * 1000.0)
	
	move_and_slide()
	
	if int(HEALTH) <= 0:
		HEALTH = 0
		await get_tree().create_timer(0.25).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		OS.alert("You died!")
		get_tree().reload_current_scene()
	
	if len(get_tree().get_nodes_in_group("Enemy")) <= 0:
		await get_tree().create_timer(0.25).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		OS.alert("You Win!")
		get_tree().reload_current_scene()
	
	# Right Joystick
	var joystick_index = 0
	var deadzone = 0.1
	var rstick_h = Input.get_joy_axis(joystick_index, JOY_AXIS_RIGHT_X)
	var rstick_v = Input.get_joy_axis(joystick_index, JOY_AXIS_RIGHT_Y)
	
	if abs(rstick_h) > deadzone:
		self.rotate_y(-rstick_h * delta * (CAM_SENSITIVITY*75))
	if abs(rstick_v) > deadzone:
		camera.rotate_x(-rstick_v * delta * (CAM_SENSITIVITY*75))
	
	pass


func take_damage(dmg, override=false, headshot=false, _spawn_origin=null):
	if damage_lock == 0.0 or override:
		damage_lock = 0.5
		HEALTH -= dmg
		#var dmg_intensity =s clamp(1.0-((HEALTH+0.01)/MAX_HEALTH), 0.1, 0.8)
		#$HUD/overlay.material = damage_shader.duplicate()
		#$HUD/overlay.material.set_shader_parameter("intensity", dmg_intensity)


func headbob(time):
	var pos = Vector3.ZERO
	pos.x = cos(time * BOB_FREQ / 2) * (BOB_AMP/2.0)
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	blaster = $Head/Camera3D/blaster
	muzzle = $Head/Camera3D/blaster/muzzle
	old_blaster_y = blaster.position.y
	


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
		camera.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))


func do_fire():
	if spray_lock == 0.0 and ammo > 0:
		ammo -= 1
		for lcv in range(25):
			var bullet = dart.instantiate();
			get_parent().add_child(bullet);
			var spr = spray;
			if not is_on_floor():
				spr *= randf_range(1.5, 5);
			bullet.do_fire(camera, muzzle, spray, attack);
			
			spray_lock = fire_delay;
		self.global_position = lerp(self.global_position, self.global_position-(Vector3(blaster.global_position.x-self.global_position.x, 0, blaster.global_position.z-self.global_position.z) * knockback), 0.1)
