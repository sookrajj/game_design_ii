extends Node3D

@export var nl = ""
 

func _physics_process(delta: float) -> void:
	if  len(get_tree().get_nodes_in_group("Enemy")) <= 0:
		if nl != "":
			var level = "res://" + nl + ".tscn"
			get_tree().change_scene_to_file(level)
		else :
			OS.alert("You Win!")
			get_tree().quit()
