extends CharacterBody3D


const walk_speed = 5.0
const sprint_speed = 100.0
const dash = 500.0
var speed = walk_speed
const JUMP_VELOCITY = 7.5


const CAM_SENSITIVITY = 0.03
@onready var camera = $Head/Camera3D
@onready var camera_arm = $SpringArm3D
@onready var cam_pos = camera.position

@onready var base_fov = camera.fov
var FOV_change = 1.0

var first_person = true

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0
var gravity = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if first_person:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotation.x = clamp(camera_arm.rotation.x, deg_to_rad(-75), deg_to_rad(75))



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("change_camera"):
		toggle_camera_parent()
	
	# Add the gravity.
	if not is_on_floor() && gravity:
		velocity += get_gravity() * delta
	if not is_on_floor() && !gravity:
		velocity += -get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#TODO walk/run anim
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
		FOV_change = 2.0
	if Input.is_action_just_released("sprint"):
		speed = walk_speed
		FOV_change = 1.0
	
	if Input.is_action_just_pressed("dash"):
		speed = dash
		FOV_change = 5.0
	
	if Input.is_action_just_pressed("gravity"):
		gravity = false
		#print(self.gravity)
		#self.gravity = Vector3(0, -1, 0)
		##(0, -9.8, 0)
	if Input.is_action_just_released("gravity"):
		gravity = true
		#self.gravity = Vector3(0, -9.8, 0)

	
	var velocity_clamped = clamp(velocity.length(), .5, speed * 2)
	var target = base_fov + FOV_change * velocity_clamped
	camera.fov = lerp(camera.fov, target, delta * 10.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)

	move_and_slide()
	#camera.position += headbob(delta)


func headbob(time):
	var pos = Vector3.ZERO
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos

func toggle_camera_parent():
	var parent = "Head"
	if first_person:
		parent = "SpringArm3D"
		#TODO: model visible
	var child = camera
	child.get_parent().remove_child(child)
	#child.reparent(parent)
	get_node(parent).add_child(child)
	camera = child
	if not first_person:
		camera.position = cam_pos
		#TODO: model invisible
	first_person = !first_person
