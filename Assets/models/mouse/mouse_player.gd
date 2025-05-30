extends CharacterBody3D


const walk_speed = 5.0
const sprint_speed = 100.0
const dash = 500.0
var speed = walk_speed
const JUMP_VELOCITY = 7.5


const CAM_SENSITIVITY = 0.03
@onready var camera = $Head/Camera3D
@onready var camera_arm = $SpringArm3D
@onready var spring_pos = camera_arm.position
@onready var cam_pos = camera.position
@onready var base_fov = camera.fov
var FOV_change = 1.0
var sper = false


var first_person = true

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0
var pushes = {
	"putter" : 50.0,
	"chipper" : 200.0,
	"iron" : 500.0,
	"hybrid" : 1000.0,
	"driver" : 2000.0
}
var push = 50.0

var inertia = Vector3.ZERO
var MAX_HEALTH = 50
var health = MAX_HEALTH
var damage_lock = 0.0
var ballpos = Vector3(0, 10, 0)
@onready var ball = preload("res://ball.tscn")

@onready var hud = $PlayerHud3d
var dmg_shader = preload("res://Assets/Shaders/take_damage.tres")

@onready var model = $AuxScene
@onready var ani = $AuxScene/AnimationPlayer
var gravity = true
var equipped = "chipper"
@onready var choose = $choose_club
var curball

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	model.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if first_person:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			self.rotate_y(-event.relative.x * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotate_x(-event.relative.y * (CAM_SENSITIVITY / 10.0))
			camera_arm.rotation.x = clamp(camera_arm.rotation.x, deg_to_rad(-45), deg_to_rad(45))



func _physics_process(delta: float) -> void:
	if ballpos == Vector3(0, 10, 0) && get_tree().get_node_count_in_group("interact") != 0 :
		ballpos = get_tree().get_first_node_in_group("interact").global_position
	if curball != get_tree().get_first_node_in_group("interact"):
		curball = get_tree().get_first_node_in_group("interact")
	if equipped != Glob.current:
		equipped = Glob.current
		push = pushes[equipped]
	if get_tree().get_node_count_in_group("interact") == 0:
		var ba = ball.instantiate()
		ba.global_position = ballpos
		get_parent().add_child(ba)
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("change_camera"):
		toggle_camera_parent()
	if Input.is_action_just_pressed("emote"):
		ani.play("HipHopDancing(1)")
	# Add the gravity.
	if not is_on_floor() && gravity:
		velocity += get_gravity() * delta
	if not is_on_floor() && !gravity:
		velocity += -get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		ani.play("Jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if speed == walk_speed && ani.current_animation == "": 
			ani.play("StrutWalking")
		elif ani.current_animation == "":
			ani.play("StrutWalking")
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
		FOV_change = 0.9
	if Input.is_action_just_released("sprint"):
		speed = walk_speed
		FOV_change = 1.0
	
	if Input.is_action_just_pressed("dash"):
		speed = dash
		FOV_change = 0.90
	if Input.is_action_just_released("dash"):
		speed = walk_speed
		FOV_change = 1.0
	if Input.is_action_just_pressed("gravity"):
		gravity = false
		ani.play("Floating")
		#print(self.gravity)
		#self.gravity = Vector3(0, -1, 0)
		##(0, -9.8, 0)
	if Input.is_action_just_released("gravity"):
		gravity = true
		#self.gravity = Vector3(0, -9.8, 0)

	if Input.is_action_just_pressed("change_club"):
		choose.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var velocity_clamped = clamp(velocity.length(), .5, speed * 2)
	var target = base_fov + FOV_change * velocity_clamped
	#camera.fov = lerp(camera.fov, target, delta * 10.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)
	
	velocity += inertia
	inertia = inertia.move_toward(Vector3.ZERO, delta * 1000.0)
	damage_lock = max(damage_lock-delta, 0.0)
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if $Feet.overlaps_area(enemy.dmg_area):
			enemy.take_damage(0)
	
	
	hud.healthbar.max_value = MAX_HEALTH
	hud.healthbar.value = int(health)
	
	for tramp in get_tree().get_nodes_in_group("trampolines"):
		if $Feet.overlaps_area(tramp.bounce):
			velocity += Vector3(0, 10, 0)
	
	if damage_lock == 0.0:
		hud.dmg_overlay.material = null
		
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		var col = c.get_collider()
		if col is RigidBody3D && col.is_in_group("interact"):
			col.apply_central_force(-c.get_normal() * push)
	
	if Input.is_action_just_pressed("ui_home"):
		if push == 1600:
			pass
		else :
			push *= 2
	if Input.is_action_just_pressed("ui_end"):
		if push == 6.25:
			pass
		else:
			push /= 2
	if Input.is_action_just_pressed("bigify"):
		if curball.scale < Vector3(100, 100, 100):
			print(curball.scale)
			curball.scale *= 2
			print(curball.scale)
			curball.position += Vector3(0, self.scale.y/2, 0)
	if Input.is_action_just_pressed("smallify"):
		if scale > Vector3(0.01, 0.01, 0.01):
			curball.scale /= 2
			print(curball.scale)
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	move_and_slide()
	#camera.position += headbob(delta)


func take_damage(dmg):
	if damage_lock == 0.0:
		damage_lock = 0.5
		health -= dmg
		var dint = clamp(1.0-((health + 0.01) / MAX_HEALTH), 0.1, 0.8)
		hud.dmg_overlay.material = dmg_shader.duplicate()
		hud.dmg_overlay.material.set_shader_parameter("intensity", dint)
		if health <= 0:
			await get_tree().create_timer(0.25).timeout
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			OS.alert("You Died!")
			get_tree().reload_current_scene()
	


func headbob(time):
	var pos = Vector3.ZERO
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos


func toggle_camera_parent():
	var parent = "Head"
	var ignore = false
	#camera_arm.position = spring_pos
	if first_person:
		parent = "SpringArm3D"
		first_person = !first_person
		sper = true
		model.visible = !first_person 
		self.get_node(parent).rotate(self.global_position.normalized(), deg_to_rad(180))
		#TODO: model visible'
	elif sper:
		parent = "SpringArm3D"
		sper = false
		self.get_node(parent).rotate(self.global_position.normalized(), deg_to_rad(180))
		ignore = true
	var child = camera
	child.get_parent().remove_child(child)
	#child.reparent(parent)
	get_node(parent).add_child(child)
	camera = child
	print(first_person, " ", sper)
	if not first_person and not sper and not ignore:
		camera.position = cam_pos
		#TODO: model invisible
		model.visible = first_person
		first_person = !first_person
