extends Node3D

@onready var blueanim = $AuxScene/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(28).timeout
	blueanim.play("Defeated0")
	await get_tree().create_timer(2).timeout
	get_tree().quit()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if blueanim.current_animation == "": blueanim.play("Running0")
