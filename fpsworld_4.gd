extends Node3D

@onready var anim = $ship_scene/AnimationPlayer

func _physics_process(delta: float) -> void:
	if anim.current_animation == "":
		anim.play("Take 01")
