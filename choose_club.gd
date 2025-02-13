extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Glob.current = "Driver"


func _on_button_2_pressed() -> void:
	Glob.current = "Hybrid"


func _on_button_3_pressed() -> void:
	Glob.current = "Iron"


func _on_button_4_pressed() -> void:
	Glob.current = "Chipper"


func _on_button_5_pressed() -> void:
	Glob.current = "Putter"
