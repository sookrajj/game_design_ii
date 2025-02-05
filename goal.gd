extends Area3D

@export var next_lvl = ""
@onready var hud = get_tree().get_first_node_in_group("Hud")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if (next_lvl != ""):
			var level = "res://" + next_lvl + ".tscn"
			hud.popup.visible = true
			hud.label.text = "Loading..."
			await get_tree().create_timer(0.1).timeout
			get_tree().change_scene_to_file(level)
		else:
			OS.alert("No next level!")
	pass # Replace with function body.
