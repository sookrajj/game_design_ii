extends CharacterBody3D

@onready var dmg_area = $DamageArea
@onready var nav_agent_3d = $NavigationAgent3D
@onready var atk_area = $Attack

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
	for player in get_tree().get_nodes_in_group("player"):
		if $AttackRange.overlaps_body(player):
			nav_agent_3d.target_position = player.global_position
		if atk_area.overlaps_body(player):
			player.take_damage(attack)
			player.inertia = (player.global_position - global_position).normalized() * knockback
	
	var direction = (nav_agent_3d.target_position - self.global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	


func _ready() -> void:
	nav_agent_3d.target_position = global_position
