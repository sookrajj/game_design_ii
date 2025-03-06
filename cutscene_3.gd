extends Node3D

@onready var blueanim = $AuxScene/AnimationPlayer
@onready var redanim = $MousePlayer/AuxScene/AnimationPlayer
var t = "FastRun0";
var o = "Running0"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(20).timeout
	redanim.play(t)
	await get_tree().create_timer(28).timeout
	t = "Taunt0"
	o = "Defeated0"
	await get_tree().create_timer(2).timeout
	get_tree().quit()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if blueanim.current_animation == "": blueanim.play(o)
	if redanim.current_animation == "": redanim.play(t)
