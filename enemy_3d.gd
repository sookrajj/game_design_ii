extends CharacterBody3D

@onready var dmg_area = $DamageArea
@onready var nav_agent_3d = $NavigationAgent3D
@onready var atk_area = $Attack
@onready var anim = $AuxScene/AnimationPlayer

var x = 0.0
var y = 0.0
var z = 0.0
var speed = 3.0
var accel = 20
var attack = 10
var knockback = 16.0

func take_damage(_dmg) :
	self.queue_free()


func _physics_process(delta: float) -> void:
	for player in get_tree().get_nodes_in_group("interact"):
		if $AttackRange.overlaps_body(player):
			print("what")
			nav_agent_3d.target_position = player.global_position
		if atk_area.overlaps_body(player):
			anim.play("Punching")
			player.queue_free()
		
	
	var direction = (nav_agent_3d.target_position - self.global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	if not is_on_floor():
		velocity += get_gravity() * delta * 10
	if direction.length() >0.1:
		self.look_at(Vector3(nav_agent_3d.target_position.x, self.global_position.y, nav_agent_3d.target_position.z), Vector3.UP)
	if velocity.length() <= 2 && anim.current_animation == "":
		anim.play("ArmStretching")
		print(anim.current_animation)
	else:
		anim.play("Walking")
	
	move_and_slide()
	


func _ready() -> void:
	nav_agent_3d.target_position = global_position
